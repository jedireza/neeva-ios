/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Defaults
import Foundation
import Shared
import Storage
import WebKit
import XCGLogger

private let log = Logger.browser

// TabManager must extend NSObjectProtocol in order to implement WKNavigationDelegate
class TabManager: NSObject {
    let tabEventHandlers: [TabEventHandler]
    let store: TabManagerStore
    var scene: UIScene
    let profile: Profile
    let incognitoModel: IncognitoModel

    let delaySelectingNewPopupTab: TimeInterval = 0.1

    static var all = WeakList<TabManager>()

    var tabs = [Tab]()
    var tabsUpdatedPublisher = PassthroughSubject<Void, Never>()

    var didRestoreAllTabs: Bool = false

    // Use `selectedTabPublisher` to observe changes to `selectedTab`.
    var selectedTab: Tab?
    var selectedTabPublisher = PassthroughSubject<Tab?, Never>()

    let navDelegate: TabManagerNavDelegate

    public static func makeWebViewConfig(isIncognito: Bool) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.phoneNumber]
        configuration.processPool = WKProcessPool()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = !Defaults[.blockPopups]
        // We do this to go against the configuration of the <meta name="viewport">
        // tag to behave the same way as Safari :-(
        configuration.ignoresViewportScaleLimits = true
        if isIncognito {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }
        configuration.setURLSchemeHandler(InternalSchemeHandler(), forURLScheme: InternalURL.scheme)

        return configuration
    }

    // A WKWebViewConfiguration used for normal tabs
    lazy var configuration: WKWebViewConfiguration = {
        return TabManager.makeWebViewConfig(isIncognito: false)
    }()

    // A WKWebViewConfiguration used for private mode tabs
    lazy var incognitoConfiguration: WKWebViewConfiguration = {
        return TabManager.makeWebViewConfig(isIncognito: true)
    }()

    // enables undo of recently closed tabs
    /// supports closing/restoring a group of tabs or a single tab (alone in an array)
    var recentlyClosedTabs = [[SavedTab]]()

    // groups tabs closed together in a certain amount of time into one Toast
    let toastGroupTimerInterval: TimeInterval = 1.5
    var timerToTabsToast: Timer?
    var closedTabsToShowToastFor = [SavedTab]()

    var normalTabs: [Tab] {
        assert(Thread.isMainThread)
        return tabs.filter { !$0.isIncognito }
    }

    var incognitoTabs: [Tab] {
        assert(Thread.isMainThread)
        return tabs.filter { $0.isIncognito }
    }

    init(profile: Profile, scene: UIScene, incognitoModel: IncognitoModel) {
        assert(Thread.isMainThread)
        self.profile = profile
        self.navDelegate = TabManagerNavDelegate()
        self.tabEventHandlers = TabEventHandlers.create()
        self.store = TabManagerStore.shared
        self.scene = scene
        self.incognitoModel = incognitoModel
        super.init()

        Self.all.insert(self)

        register(self, forTabEvents: .didLoadFavicon, .didChangeContentBlocking)

        addNavigationDelegate(self)

        NotificationCenter.default.addObserver(
            self, selector: #selector(prefsDidChange), name: UserDefaults.didChangeNotification,
            object: nil)

        ScreenCaptureHelper.defaultHelper.subscribeToTabUpdates(
            from: selectedTabPublisher.eraseToAnyPublisher())
    }

    func addNavigationDelegate(_ delegate: WKNavigationDelegate) {
        assert(Thread.isMainThread)

        self.navDelegate.insert(delegate)
    }

    var count: Int {
        assert(Thread.isMainThread)

        return tabs.count
    }

    var isIncognito: Bool {
        incognitoModel.isIncognito
    }

    subscript(index: Int) -> Tab? {
        assert(Thread.isMainThread)

        if index >= tabs.count {
            return nil
        }
        return tabs[index]
    }

    subscript(webView: WKWebView) -> Tab? {
        assert(Thread.isMainThread)

        for tab in tabs where tab.webView === webView {
            return tab
        }

        return nil
    }

    // MARK: - Get Tab
    func getTabFor(_ url: URL) -> Tab? {
        assert(Thread.isMainThread)

        let options: [URL.EqualsOption] = [.normalizeHost, .ignoreFragment, .ignoreLastSlash]

        log.info("Looking for matching tab, url: \(url)")

        for tab in tabs.filter({ $0.isIncognito == self.isIncognito }) {
            // Tab.url will be nil if the Tab is yet to be restored.
            if let tabUrl = tab.url {
                log.info("Checking tabUrl: \(tabUrl)")
                if url.equals(tabUrl, with: options) {
                    return tab
                }
            } else if let sessionUrl = tab.sessionData?.currentUrl {  // Match zombie tabs
                log.info("Checking sessionUrl: \(sessionUrl)")
                if url.equals(sessionUrl, with: options) {
                    return tab
                }

                if let internalUrl = InternalURL(sessionUrl), internalUrl.isSessionRestore,
                    let extractedUrlParam = internalUrl.extractedUrlParam
                {
                    log.info("Checking extractedUrlParam: \(extractedUrlParam)")
                    if url.equals(extractedUrlParam, with: options) {
                        return tab
                    }
                }
            }
        }

        return nil
    }

    func getTabCountForCurrentType() -> Int {
        let isIncognito = isIncognito

        if isIncognito {
            return incognitoTabs.count
        } else {
            return normalTabs.count
        }
    }

    func getTabForUUID(uuid: String) -> Tab? {
        assert(Thread.isMainThread)
        let filterdTabs = tabs.filter { tab -> Bool in
            tab.tabUUID == uuid
        }
        return filterdTabs.first
    }

    // MARK: - Select Tab
    // This function updates the _selectedIndex.
    // Note: it is safe to call this with `tab` and `previous` as the same tab, for use in the case where the index of the tab has changed (such as after deletion).
    func selectTab(_ tab: Tab?, previous: Tab? = nil, notify: Bool = true) {
        assert(Thread.isMainThread)
        let previous = previous ?? selectedTab

        // Make sure to wipe the private tabs if the user has the pref turned on
        if Defaults[.closeIncognitoTabs], !(tab?.isIncognito ?? false), incognitoTabs.count > 0 {
            removeAllIncognitoTabs()
        }

        selectedTab = tab

        incognitoModel.update(isIncognito: tab?.isIncognito ?? false)
        store.preserveTabs(tabs, selectedTab: selectedTab, for: scene)

        assert(tab === selectedTab, "Expected tab is selected")

        selectedTab?.createWebview()
        selectedTab?.lastExecutedTime = Date.nowMilliseconds()

        if notify {
            sendSelectTabNotifications(previous: previous)
        }

        if let tab = selectedTab {
            tab.applyTheme()
        }

        if let tab = tab, tab.isIncognito, let url = tab.url, NeevaConstants.isAppHost(url.host),
            !url.path.starts(with: "/incognito")
        {
            tab.webView?.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                if cookies.first(where: {
                    NeevaConstants.isAppHost($0.domain) && $0.name == "httpd~incognito"
                        && $0.isSecure
                }) != nil {
                    return
                }

                StartIncognitoMutation(url: url).perform { result in
                    guard
                        case .success(let data) = result,
                        let url = URL(string: data.startIncognito)
                    else { return }
                    let configuration = URLSessionConfiguration.ephemeral
                    makeURLSession(userAgent: UserAgent.getUserAgent(), configuration: .ephemeral)
                        .dataTask(with: url) { (data, response, error) in
                            print(configuration.httpCookieStorage?.cookies ?? [])
                        }
                }
            }
        }
    }

    //Called by other classes to signal that they are entering/exiting private mode
    //This is called by TabTrayVC when the private mode button is pressed and BEFORE we've switched to the new mode
    //we only want to remove all private tabs when leaving PBM and not when entering.
    func willSwitchTabMode(leavingPBM: Bool) {
        // Clear every time entering/exiting this mode.
        Tab.ChangeUserAgent.privateModeHostList = Set<String>()

        if Defaults[.closeIncognitoTabs] && leavingPBM {
            removeAllIncognitoTabs()
        }
    }

    // MARK: - Incognito
    // TODO(darin): Refactor these methods to set incognito mode. These should probably
    // move to `BrowserModel` and `TabManager` should just observe `IncognitoModel`.
    func setIncognitoMode(to isIncognito: Bool) {
        self.incognitoModel.update(isIncognito: isIncognito)
    }

    func toggleIncognitoMode(
        fromTabTray: Bool = true, clearSelectedTab: Bool = true, openLazyTab: Bool = true
    ) {
        let bvc = SceneDelegate.getBVC(with: scene)

        // set to nil while inconito changes
        if clearSelectedTab {
            selectedTab = nil
        }

        incognitoModel.toggle()

        if let mostRecentTab = mostRecentTab(inTabs: isIncognito ? incognitoTabs : normalTabs) {
            selectTab(mostRecentTab)
        } else if isIncognito && openLazyTab {  // no empty tab tray in incognito
            bvc.openLazyTab(openedFrom: fromTabTray ? .tabTray : .openTab(selectedTab))
        } else {
            let placeholderTab = Tab(
                bvc: bvc, configuration: configuration, isIncognito: isIncognito)

            // Creates a placeholder Tab to make sure incognito is switched in the Top Bar
            select(placeholderTab)
        }
    }

    func switchIncognitoMode(
        incognito: Bool, fromTabTray: Bool = true, clearSelectedTab: Bool = true,
        openLazyTab: Bool = true
    ) {
        if isIncognito != incognito {
            toggleIncognitoMode(
                fromTabTray: fromTabTray, clearSelectedTab: clearSelectedTab,
                openLazyTab: openLazyTab)
        }
    }

    // Select the most recently visited tab, IFF it is also the parent tab of the closed tab.
    func selectParentTab(afterRemoving tab: Tab) -> Bool {
        let viableTabs = (tab.isIncognito ? incognitoTabs : normalTabs).filter { $0 != tab }
        guard let parentTab = tab.parent, parentTab != tab, !viableTabs.isEmpty,
            viableTabs.contains(parentTab)
        else { return false }

        let parentTabIsMostRecentUsed = mostRecentTab(inTabs: viableTabs) == parentTab

        if parentTabIsMostRecentUsed, parentTab.lastExecutedTime != nil {
            selectTab(parentTab, previous: tab)
            return true
        }
        return false
    }

    @objc func prefsDidChange() {
        DispatchQueue.main.async {
            let allowPopups = !Defaults[.blockPopups]
            // Each tab may have its own configuration, so we should tell each of them in turn.
            for tab in self.tabs {
                tab.webView?.configuration.preferences.javaScriptCanOpenWindowsAutomatically =
                    allowPopups
            }
            // The default tab configurations also need to change.
            self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = allowPopups
            self.incognitoConfiguration.preferences.javaScriptCanOpenWindowsAutomatically =
                allowPopups
        }
    }

    func addPopupForParentTab(
        bvc: BrowserViewController, parentTab: Tab, configuration: WKWebViewConfiguration
    ) -> Tab {
        let popup = Tab(bvc: bvc, configuration: configuration, isIncognito: parentTab.isIncognito)
        configureTab(
            popup, request: nil, afterTab: parentTab, flushToDisk: true, zombie: false,
            isPopup: true, notify: true)

        // Wait momentarily before selecting the new tab, otherwise the parent tab
        // may be unable to set `window.location` on the popup immediately after
        // calling `window.open("")`.
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySelectingNewPopupTab) {
            self.selectTab(popup)
        }

        return popup
    }

    func resetProcessPool() {
        assert(Thread.isMainThread)
        configuration.processPool = WKProcessPool()
    }

    func sendSelectTabNotifications(previous: Tab? = nil) {
        if let tab = selectedTab {
            selectedTabPublisher.send(tab)
        }

        if let tab = previous {
            TabEvent.post(.didLoseFocus, for: tab)
        }

        if let tab = selectedTab {
            TabEvent.post(.didGainFocus, for: tab)
        }
    }
}
