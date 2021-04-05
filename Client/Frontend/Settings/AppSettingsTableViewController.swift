/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

/// App Settings Screen (triggered by tapping the 'Gear' in the Tab Tray Controller)
class AppSettingsTableViewController: SettingsTableViewController {
    var showContentBlockerSetting = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = .AppSettingsTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: .AppSettingsDone,
            style: .done,
            target: navigationController, action: #selector((navigationController as! ThemedNavigationController).done))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "AppSettingsTableViewController.navigationItem.leftBarButtonItem"

        tableView.accessibilityIdentifier = "AppSettingsTableViewController.tableView"

        // Refresh the user's FxA profile upon viewing settings. This will update their avatar,
        // display name, etc.
        ////profile.rustAccount.refreshProfile()

        // Asking for a fresh UserInfo before showing Browser Settings and showing Profile data. 
        NeevaUserInfo.shared.fetch()

        if showContentBlockerSetting {
            let viewController = ContentBlockerSettingViewController(prefs: profile.prefs)
            viewController.profile = profile
            viewController.tabManager = tabManager
            navigationController?.pushViewController(viewController, animated: false)
            // Add a done button from this view
            viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        }
    }

    override func generateSettings() -> [SettingSection] {
        var settings = [SettingSection]()

        let prefs = profile.prefs
        var generalSettings: [Setting] = [
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.KeyShowSearchSuggestions, defaultValue: true,
                                    titleText: NSLocalizedString("Show Search Suggestions", comment: "Label for show search suggestions setting.")),
            NewTabPageSetting(settings: self),
            OpenWithSetting(settings: self),
            ThemeSetting(settings: self),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.KeyBlockPopups, defaultValue: true,
                        titleText: .AppSettingsBlockPopups),
           ]

        if #available(iOS 12.0, *) {
            generalSettings.insert(SiriPageSetting(settings: self), at: 5)
        }

        // There is nothing to show in the Customize section if we don't include the compact tab layout
        // setting on iPad. When more options are added that work on both device types, this logic can
        // be changed.

        generalSettings += [
            BoolSetting(prefs: prefs, prefKey: "showClipboardBar", defaultValue: false,
                        titleText: Strings.SettingsOfferClipboardBarTitle,
                        statusText: Strings.SettingsOfferClipboardBarStatus),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.ContextMenuShowLinkPreviews, defaultValue: true,
                        titleText: Strings.SettingsShowLinkPreviewsTitle,
                        statusText: Strings.SettingsShowLinkPreviewsStatus)
        ]

        var neevaSettings: [Setting] = [
            NeevaProfileSetting(settings: self, delegate: settingsDelegate),
            NeevaSearchSetting(delegate: settingsDelegate)
        ]

        if #available(iOS 14.0, *) {
            neevaSettings += [
                DefaultBrowserSetting(settings: self)
            ]
        }

        settings += [ SettingSection(title: NSAttributedString(string: Strings.SettingsNeevaSectionTitle), children: neevaSettings)]

        settings += [ SettingSection(title: NSAttributedString(string: Strings.SettingsGeneralSectionTitle), children: generalSettings)]

        var privacySettings = [Setting]()
        privacySettings.append(ClearPrivateDataSetting(settings: self))

        privacySettings += [
            BoolSetting(prefs: prefs,
                prefKey: "settings.closePrivateTabs",
                defaultValue: false,
                titleText: .AppSettingsClosePrivateTabsTitle,
                statusText: .AppSettingsClosePrivateTabsDescription)
        ]

        privacySettings.append(ContentBlockerSetting(settings: self))

        privacySettings += [
            PrivacyPolicySetting()
        ]

        settings += [
            SettingSection(title: NSAttributedString(string: .AppSettingsPrivacyTitle), children: privacySettings),
            SettingSection(title: NSAttributedString(string: .AppSettingsSupport), children: [
                ShowIntroductionSetting(settings: self),
                SendFeedbackSetting(),
                OpenSupportPageSetting(delegate: settingsDelegate),
            ]),
            SettingSection(title: NSAttributedString(string: .AppSettingsAbout), children: [
                VersionSetting(settings: self),
                LicenseAndAcknowledgementsSetting(),
                YourRightsSetting(),
                NeevaHostSetting(settings: self),
                NeevaAdminLinkSetting(settings: self),
                ExportBrowserDataSetting(settings: self),
                ExportLogDataSetting(settings: self),
                DeleteExportedDataSetting(settings: self),
                ForceCrashSetting(settings: self),
                SlowTheDatabase(settings: self),
                ToggleChronTabs(settings: self)
            ])]

        if NeevaUserInfo.shared.isUserLoggedIn {
            settings += [SettingSection(children: [SignOutSetting(delegate: settingsDelegate)])]
        }

        return settings
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = super.tableView(tableView, viewForHeaderInSection: section) as! ThemedTableSectionHeaderFooterView
        return headerView
    }
}
