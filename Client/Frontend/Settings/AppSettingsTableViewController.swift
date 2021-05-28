/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import Defaults

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

        // Asking for UserInfo before showing Browser Settings and showing Profile data if user is login.
        if (NeevaUserInfo.shared.hasLoginCookie()) {
            NeevaUserInfo.shared.loadUserInfoFromDefaults()
        }

        if showContentBlockerSetting {
            let viewController = ContentBlockerSettingViewController()
            viewController.profile = profile
            viewController.tabManager = tabManager
            navigationController?.pushViewController(viewController, animated: false)
            // Add a done button from this view
            viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        }
    }

    override func generateSettings() -> [SettingSection] {
        var settings = [SettingSection]()

        var generalSettings: [Setting] = [
            BoolSetting(prefKey: Defaults.Keys.showSearchSuggestions.name, defaultValue: true,
                                    titleText: NSLocalizedString("Show Search Suggestions", comment: "Label for show search suggestions setting.")),
            OpenWithSetting(settings: self),
            BoolSetting(prefKey: Defaults.Keys.blockPopups.name, defaultValue: true,
                        titleText: .AppSettingsBlockPopups),
           ]

        if #available(iOS 12.0, *) {
            generalSettings.append(SiriPageSetting(settings: self))
        }

        // There is nothing to show in the Customize section if we don't include the compact tab layout
        // setting on iPad. When more options are added that work on both device types, this logic can
        // be changed.

        generalSettings += [
            BoolSetting(prefKey: Defaults.Keys.showClipboardBar.name, defaultValue: false,
                        titleText: Strings.SettingsOfferClipboardBarTitle,
                        statusText: Strings.SettingsOfferClipboardBarStatus),
            BoolSetting(prefKey: Defaults.Keys.contextMenuShowLinkPreviews.name, defaultValue: true,
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
            BoolSetting(
                prefKey: Defaults.Keys.closePrivateTabs.name,
                defaultValue: false,
                titleText: .AppSettingsClosePrivateTabsTitle,
                statusText: .AppSettingsClosePrivateTabsDescription
            )
        ]

        privacySettings.append(ContentBlockerSetting(settings: self))

        privacySettings += [
            PrivacyPolicySetting()
        ]

        settings += [
            SettingSection(title: NSAttributedString(string: .AppSettingsPrivacyTitle), children: privacySettings),
            SettingSection(title: NSAttributedString(string: .AppSettingsSupport), children: [
                ShowIntroductionSetting(settings: self),
                SendFeedbackSetting(delegate: settingsDelegate),
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
                FeatureFlagSetting(settings: self),
            ])]

        if NeevaUserInfo.shared.hasLoginCookie() {
            settings += [SettingSection(children: [SignOutSetting(delegate: settingsDelegate)])]
        }

        return settings
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = super.tableView(tableView, viewForHeaderInSection: section) as! ThemedTableSectionHeaderFooterView
        return headerView
    }
}
