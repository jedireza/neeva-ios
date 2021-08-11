/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import AVFoundation
import BackgroundTasks
import CoreSpotlight
import Defaults
import LocalAuthentication
import MessageUI
import SDWebImage
import Shared
import Storage
import SwiftKeychainWrapper
import UserNotifications
import XCGLogger

private let log = Logger.browser

class AppDelegate: UIResponder, UIApplicationDelegate, UIViewControllerRestoration {
    public static func viewController(
        withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder
    ) -> UIViewController? {
        return nil
    }

    var applicationCleanlyBackgrounded = true
    var shutdownWebServer: DispatchSourceTimer?
    var orientationLock = UIInterfaceOrientationMask.all
    weak var application: UIApplication?
    var launchOptions: [AnyHashable: Any]?
    var receivedURLs = [URL]()

    var profile: Profile?

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        //
        // Determine if the application cleanly exited last time it was used.
        // Check if the "applicationCleanlyBackgrounded" user
        // default exists and whether was properly set to true on app exit.
        //
        // Then we always set the user default to false. It will be set to true when we the application
        // is backgrounded.
        //

        self.applicationCleanlyBackgrounded = Defaults[.applicationCleanlyBackgrounded]
        Defaults[.applicationCleanlyBackgrounded] = false

        let profile = createProfile()
        self.profile = profile

        // Set up a web server that serves us static content. Do this early so that it is ready when the UI is presented.
        setUpWebServer(profile)

        // Hold references to willFinishLaunching parameters for delayed app launch
        self.application = application
        self.launchOptions = launchOptions

        // Cleanup can be a heavy operation, take it out of the startup path. Instead check after a few seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            profile.cleanupHistoryIfNeeded()
        }

        return startApplication(application, withLaunchOptions: launchOptions)
    }

    func startApplication(
        _ application: UIApplication, withLaunchOptions launchOptions: [AnyHashable: Any]?
    ) -> Bool {
        log.info("startApplication begin")

        // log last crashed status and page load number
        // we use applicationCleanlyBackgrounded in Default to keep track
        // if sceneDidEnterBackground or sceneDidEnterBackground triggered
        // before the app enter background or close, we use it as a proxy
        // to determine if there is a crash from last exit
        PerformanceLogger.shared.logPageLoadWithCrashedStatus(
            crashed: !self.applicationCleanlyBackgrounded)

        // Need to get "settings.sendUsageData" this way so that Sentry can be initialized
        // before getting the Profile.
        let sendUsageData = false
        Sentry.shared.setup(sendUsageData: sendUsageData)

        // Set the Neeva UA for browsing.
        setUserAgent()

        // Start the keyboard helper to monitor and cache keyboard state.
        KeyboardHelper.defaultHelper.startObserving()

        DynamicFontHelper.defaultHelper.startObserving()

        MenuHelper.defaultHelper.setItems()

        SystemUtils.onFirstRun()

        log.info("startApplication end")

        return true
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        var shouldPerformAdditionalDelegateHandling = true

        Logger.rollLogs()

        // If a shortcut was launched, display its information and take the appropriate action
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem]
            as? UIApplicationShortcutItem
        {
            QuickActions.sharedInstance.launchedShortcutItem = shortcutItem
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = false
        }

        return shouldPerformAdditionalDelegateHandling
    }

    // We sync in the foreground only, to avoid the possibility of runaway resource usage.
    // Eventually we'll sync in response to notifications.
    func applicationDidBecomeActive(_ application: UIApplication) {
        shutdownWebServer?.cancel()
        shutdownWebServer = nil

        // Resume file downloads.
        // TODO: iOS 13 needs to iterate all the BVCs.
        SceneDelegate.getBVC().downloadQueue.resumeAll()

        // handle quick actions is available
        let quickActions = QuickActions.sharedInstance
        if let shortcut = quickActions.launchedShortcutItem {
            // dispatch asynchronously so that BVC is all set up for handling new tabs
            // when we try and open them
            quickActions.handleShortCutItem(
                shortcut, withBrowserViewController: SceneDelegate.getBVC())
            quickActions.launchedShortcutItem = nil
        }

        // Delay these operations until after UIKit/UIApp init is complete
        // - loadQueuedTabs accesses the DB and shows up as a hot path in profiling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // We could load these here, but then we have to futz with the tab counter
            // and making NSURLRequests.
            SceneDelegate.getBVC().loadQueuedTabs(receivedURLs: self.receivedURLs)
            self.receivedURLs.removeAll()
            application.applicationIconBadgeNumber = 0
        }

        updateTopSitesWidget()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        updateTopSitesWidget()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Pause file downloads.
        // TODO: iOS 13 needs to iterate all the BVCs.
        SceneDelegate.getBVC().downloadQueue.pauseAll()

        let singleShotTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        // 2 seconds is ample for a localhost request to be completed by GCDWebServer. <500ms is expected on newer devices.
        singleShotTimer.schedule(deadline: .now() + 2.0, repeating: .never)
        singleShotTimer.setEventHandler {
            WebServer.sharedInstance.server.stop()
            self.shutdownWebServer = nil
        }
        singleShotTimer.resume()
        shutdownWebServer = singleShotTimer
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // We have only five seconds here, so let's hope this doesn't take too long?.
        // Set applicationCleanlyBackgrounded to true when user manually close the app
        Defaults[.applicationCleanlyBackgrounded] = true
        profile?._shutdown()
    }

    /// We maintain a weak reference to the profile so that we can pause timed
    /// syncs when we're backgrounded.
    ///
    /// The long-lasting ref to the profile lives in `BrowserViewController`,
    /// which we set in `application:willFinishLaunchingWithOptions:`.
    ///
    /// If that ever disappears, we won't be able to grab the profile to stop
    /// syncing... but in that case the profile's deinit will take care of things.
    func createProfile() -> Profile {
        return BrowserProfile(localName: "profile")
    }

    fileprivate func setUserAgent() {
        let neevaUA = UserAgent.getUserAgent()

        // Set the UA for WKWebView (via defaults), the favicon fetcher, and the image loader.
        // This only needs to be done once per runtime. Note that we use defaults here that are
        // readable from extensions, so they can just use the cached identifier.
        SDWebImageDownloader.shared.setValue(neevaUA, forHTTPHeaderField: "User-Agent")

        //SDWebImage is setting accept headers that report we support webp. We don't
        SDWebImageDownloader.shared.setValue("image/*;q=0.8", forHTTPHeaderField: "Accept")

        // Some sites will only serve HTML that points to .ico files.
        // The FaviconFetcher is explicitly for getting high-res icons, so use the desktop user agent.
        FaviconFetcher.userAgent = UserAgent.desktopUserAgent()
    }
    fileprivate func setUpWebServer(_ profile: Profile) {
        let server = WebServer.sharedInstance
        guard !server.server.isRunning else { return }

        ReaderModeHandlers.register(server, profile: profile)

        let responders: [(String, InternalSchemeResponse)] =
            [
                (AboutHomeHandler.path, AboutHomeHandler()),
                (AboutLicenseHandler.path, AboutLicenseHandler()),
                (SessionRestoreHandler.path, SessionRestoreHandler()),
                (ErrorPageHandler.path, ErrorPageHandler()),
            ]
        responders.forEach { (path, responder) in
            InternalSchemeHandler.responders[path] = responder
        }

        if AppConstants.IsRunningTest || AppConstants.IsRunningPerfTest {
            registerHandlersForTestMethods(server: server.server)
        }

        // Bug 1223009 was an issue whereby CGDWebserver crashed when moving to a background task
        // catching and handling the error seemed to fix things, but we're not sure why.
        // Either way, not implicitly unwrapping a try is not a great way of doing things
        // so this is better anyway.
        do {
            try server.start()
        } catch let err as NSError {
            print("Error: Unable to start WebServer \(err)")
        }
    }

    private func updateTopSitesWidget() {
        guard let profile = self.profile else { return }
        TopSitesHandler.writeWidgetKitTopSites(profile: profile)
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {

    }
}

func getAppDelegateProfile() -> Profile {
    return (UIApplication.shared.delegate as? AppDelegate)!.profile!
}
