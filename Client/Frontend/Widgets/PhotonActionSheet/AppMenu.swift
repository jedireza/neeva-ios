/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SwiftUI
import NeevaSupport

public class SendFeedbackPanel: UIHostingController<SendFeedbackView> {
    init() {
        super.init(rootView: SendFeedbackView())
        rootView = SendFeedbackView(onDismiss: dismissVC)

        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotonActionSheetProtocol {

    //Returns a list of actions which is used to build a menu
    //OpenURL is a closure that can open a given URL in some view controller. It is up to the class using the menu to know how to open it
    func getLibraryActions(vcDelegate: PageOptionsVC) -> [UIMenuElement] {
        guard let tab = self.tabManager.selectedTab else { return [] }

        let openLibrary = UIAction(title: Strings.AppMenuLibraryTitleString, image: UIImage(systemName: "books.vertical")) { _ in
            let bvc = vcDelegate as? BrowserViewController
            bvc?.showLibrary()
        }

        let openHomePage = UIAction(title: Strings.AppMenuOpenHomePageTitleString, image: UIImage(systemName: "house")) { _ in
            let page = NewTabAccessors.getHomePage(self.profile.prefs)
            if page == .neevaHome {
                tab.loadRequest(URLRequest(url: NeevaConstants.appURL))
            } else if page == .homePage, let homePageURL = HomeButtonHomePageAccessors.getHomePage(self.profile.prefs) {
                tab.loadRequest(PrivilegedRequest(url: homePageURL) as URLRequest)
            } else if let homePanelURL = page.url {
                tab.loadRequest(PrivilegedRequest(url: homePanelURL) as URLRequest)
            }
        }

        let openSpaces = UIAction(title: "Spaces", image: UIImage(systemName: "bookmark")) { _ in
            let host = UIHostingController(
                rootView: SpaceListView(onDismiss: vcDelegate.dismissVC)
                    .environment(\.onOpenURL) { url in
                        vcDelegate.settingsOpenURLInNewTab(url)
                        vcDelegate.dismissVC()
                    }
            )
            host.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
            vcDelegate.present(host, animated: true, completion: nil)
        }

        var actions = [openHomePage, openLibrary]
        if let bvc = vcDelegate as? BrowserViewController {
            if !(bvc.tabManager.selectedTab?.isPrivate ?? false) {
                actions.append(openSpaces)
            }
        } else {
            print("INVALID host for app menu", vcDelegate)
        }

        return actions
    }

    func getOtherPanelActions(vcDelegate: PageOptionsVC) -> [UIMenuElement] {
        var items: [UIMenuElement] = []

        let nightModeEnabled = NightModeHelper.isActivated(profile.prefs)
        let nightMode = UIAction(title: "\(nightModeEnabled ? "Disable" : "Enable") Night Mode", image: UIImage(systemName: nightModeEnabled ? "sunrise" : "moon")) { _ in
            NightModeHelper.toggle(self.profile.prefs, tabManager: self.tabManager)
            // If we've enabled night mode and the theme is normal, enable dark theme
            if NightModeHelper.isActivated(self.profile.prefs), ThemeManager.instance.currentName == .normal {
                ThemeManager.instance.current = DarkTheme()
                NightModeHelper.setEnabledDarkTheme(self.profile.prefs, darkTheme: true)
            }
            // If we've disabled night mode and dark theme was activated by it then disable dark theme
            if !NightModeHelper.isActivated(self.profile.prefs), NightModeHelper.hasEnabledDarkTheme(self.profile.prefs), ThemeManager.instance.currentName == .dark {
                ThemeManager.instance.current = NormalTheme()
                NightModeHelper.setEnabledDarkTheme(self.profile.prefs, darkTheme: false)
            }
        }
        items.append(nightMode)

        let sendFeedback = UIAction(title: "Send Feedback", image: UIImage(systemName: "bubble.left")) { _ in
            vcDelegate.present(SendFeedbackPanel(), animated: true)
        }
        items.append(sendFeedback)

        let openSettings = UIAction(title: Strings.AppMenuSettingsTitleString, image: UIImage(systemName: "gearshape")) { _ in
            let settingsTableViewController = AppSettingsTableViewController()
            settingsTableViewController.profile = self.profile
            settingsTableViewController.tabManager = self.tabManager
            settingsTableViewController.settingsDelegate = vcDelegate

            let controller = ThemedNavigationController(rootViewController: settingsTableViewController)
            // On iPhone iOS13 the WKWebview crashes while presenting file picker if its not full screen. Ref #6232
            // since there are no intentional uses of file pickers in the web views under the Settings screen, we
            // can remove this workaround and get the better iOS 13 UX
            // if UIDevice.current.userInterfaceIdiom == .phone {
            //     controller.modalPresentationStyle = .fullScreen
            // }
            controller.presentingModalViewControllerDelegate = vcDelegate

            // Wait to present VC in an async dispatch queue to prevent a case where dismissal
            // of this popover on iPad seems to block the presentation of the modal VC.
            DispatchQueue.main.async {
                vcDelegate.present(controller, animated: true, completion: nil)
            }
        }
        items.append(openSettings)

        return items
    }
}
