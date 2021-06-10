/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import SwiftKeychainWrapper
import LocalAuthentication
import Defaults

// This file contains all of the settings available in the main settings screen of the app.

private var ShowDebugSettings: Bool = false
private var DebugSettingsClickCount: Int = 0

private var disclosureIndicator: UIImageView {
    let disclosureIndicator = UIImageView()
    disclosureIndicator.image = UIImage(named: "menu-Disclosure")?.withRenderingMode(.alwaysTemplate)
    disclosureIndicator.tintColor = UIColor.theme.tableView.accessoryViewTint
    disclosureIndicator.sizeToFit()
    return disclosureIndicator
}

// For great debugging!
class HiddenSetting: Setting {
    unowned let settings: SettingsTableViewController

    init(settings: SettingsTableViewController) {
        self.settings = settings
        super.init(title: nil)
    }

    override var hidden: Bool {
        return !ShowDebugSettings
    }
}

class DeleteExportedDataSetting: HiddenSetting {
    override var title: NSAttributedString? {
        // Not localized for now.
        return NSAttributedString(string: "Debug: delete exported databases", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsPath)
            for file in files {
                if file.hasPrefix("browser.") || file.hasPrefix("logins.") {
                    try fileManager.removeItemInDirectory(documentsPath, named: file)
                }
            }
        } catch {
            print("Couldn't delete exported data: \(error).")
        }
    }
}

class ExportBrowserDataSetting: HiddenSetting {
    override var title: NSAttributedString? {
        // Not localized for now.
        return NSAttributedString(string: "Debug: copy databases to app container", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do {
            let log = Logger.syncLogger
            try self.settings.profile.files.copyMatching(fromRelativeDirectory: "", toAbsoluteDirectory: documentsPath) { file in
                log.debug("Matcher: \(file)")
                return file.hasPrefix("browser.") || file.hasPrefix("logins.") || file.hasPrefix("metadata.")
            }
        } catch {
            print("Couldn't export browser data: \(error).")
        }
    }
}

class ExportLogDataSetting: HiddenSetting {
    override var title: NSAttributedString? {
        // Not localized for now.
        return NSAttributedString(string: "Debug: copy log files to app container", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        Logger.copyPreviousLogsToDocuments()
    }
}

class NeevaProfileSetting: Setting {
    unowned var settings: SettingsTableViewController

    private let profilePictureSize = CGSize(width: 30, height: 30)
    private let profileStringAttrs = [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]

    override var title: NSAttributedString? {
        guard let displayName = NeevaUserInfo.shared.displayName else {
            return NSAttributedString(string: Strings.NeevaSignInToNeeva, attributes: profileStringAttrs)
        }

        return NSAttributedString(string: "\(displayName)", attributes: profileStringAttrs)
    }

    override var status: NSAttributedString? {
        guard let email = NeevaUserInfo.shared.email else {
            return nil
        }

        return NSAttributedString(string: "\(email)", attributes: profileStringAttrs)
    }

    override var image: UIImage? {
        guard let userPictureData = NeevaUserInfo.shared.pictureData else {
            return UIImage(named: "placeholder-avatar")!.createScaled(profilePictureSize)
        }

        return UIImage(data: userPictureData)?.createScaled(profilePictureSize)
    }

    init(settings: SettingsTableViewController, delegate: SettingsDelegate?) {
        self.settings = settings
        super.init(title: NSAttributedString(string: Strings.NeevaSignInToNeeva, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]), delegate: delegate)
    }

    override func onConfigureCell(_ cell: UITableViewCell) {
        super.onConfigureCell(cell)

        if NeevaUserInfo.shared.hasLoginCookie() {
            cell.selectionStyle = .none
        } else {
            cell.selectionStyle = .default
        }

        if let imageView = cell.imageView {
            imageView.subviews.forEach({ $0.removeFromSuperview() })
            imageView.frame = CGRect(size: profilePictureSize)
            imageView.layer.cornerRadius = (imageView.frame.height) / 2
            imageView.layer.masksToBounds = true
        }
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.SettingSignin, attributes: EnvironmentHelper.shared.getAttributes())
        if !NeevaUserInfo.shared.hasLoginCookie() {
            navigationController?.dismiss(animated: true) {
                self.delegate?.settingsOpenURLInNewTab(NeevaConstants.appSigninURL)
            }
        }
    }
}

class NeevaSearchSetting: Setting {
    init(delegate: SettingsDelegate?) {
        super.init(title: NSAttributedString(string: .AppNeevaSettingsSearch, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]),
            delegate: delegate)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.SettingAccountSettings, attributes: EnvironmentHelper.shared.getAttributes())
        navigationController?.dismiss(animated: true) {
            // Note, we need to force Neeva Account Settings to load in a non-private tab
            // since it operates on the signed-in user's account.
            self.delegate?.settingsOpenURLInNewNonPrivateTab(NeevaConstants.appSettingsURL)
        }
    }
}

class NeevaHostSetting: HiddenSetting {
    override var title: NSAttributedString? {
        NSAttributedString(string: "Debug: Neeva appHost (\(NeevaConstants.appHost))", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }
    override func onClick(_ navigationController: UINavigationController?) {
        let alert = UIAlertController(title: "Enter custom Neeva server", message: "Default is alpha.neeva.co", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            NeevaConstants.appHost = alert.textFields!.first!.text!
        }

        alert.addAction(saveAction)
        alert.addTextField { tf in
            tf.placeholder = "Neeva server domain (required)"
            tf.text = NeevaConstants.appHost
            tf.keyboardType = .URL
            tf.clearButtonMode = .always
            if #available(iOS 14, *) {
                tf.addAction(UIAction { _ in
                    saveAction.isEnabled = tf.hasText
                }, for: .editingChanged)

                tf.returnKeyType = .done
                tf.addAction(UIAction { _ in
                    saveAction.accessibilityActivate()
                }, for: .primaryActionTriggered)
            }
        }
        navigationController!.present(alert, animated: true, completion: nil)
    }
}

class NeevaAdminLinkSetting: HiddenSetting {
    override var title: NSAttributedString? {
        NSAttributedString(string: "Debug: Neeva Admin", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }
    override func onClick(_ navigationController: UINavigationController?) {
        navigationController?.dismiss(animated: true) {
            if let url = URL(string: "\(NeevaConstants.appURL)admin") {
                self.settings.settingsDelegate?.settingsOpenURLInNewTab(url)
            }
        }
    }
}

class ForceCrashSetting: HiddenSetting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: "Debug: Force Crash", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        Sentry.shared.crash()
    }
}

class SlowTheDatabase: HiddenSetting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: "Debug: simulate slow database operations", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        debugSimulateSlowDBOperations = !debugSimulateSlowDBOperations
    }
}

// Show the current version of Firefox
class VersionSetting: Setting {
    unowned let settings: SettingsTableViewController

    override var accessibilityIdentifier: String? { return "FxVersion" }

    init(settings: SettingsTableViewController) {
        self.settings = settings
        super.init(title: nil)
    }

    override var title: NSAttributedString? {
        return NSAttributedString(string: "\(AppName.longName) \(VersionSetting.appVersion) (\(VersionSetting.appBuildNumber))", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }
    
    public static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    public static var appBuildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

    override func onConfigureCell(_ cell: UITableViewCell) {
        super.onConfigureCell(cell)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        DebugSettingsClickCount += 1
        if DebugSettingsClickCount >= 5 {
            DebugSettingsClickCount = 0
            ShowDebugSettings = !ShowDebugSettings
            settings.tableView.reloadData()
        }
    }

    override func onLongPress(_ navigationController: UINavigationController?) {
        copyAppVersionAndPresentAlert(by: navigationController)
    }

    func copyAppVersionAndPresentAlert(by navigationController: UINavigationController?) {
        let alertTitle = Strings.SettingsCopyAppVersionAlertTitle
        let alert = AlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        getSelectedCell(by: navigationController)?.setSelected(false, animated: true)
        UIPasteboard.general.string = self.title?.string
        navigationController?.topViewController?.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true)
            }
        }
    }
    
    func getSelectedCell(by navigationController: UINavigationController?) -> UITableViewCell? {
        let controller = navigationController?.topViewController
        let tableView = (controller as? AppSettingsTableViewController)?.tableView
        guard let indexPath = tableView?.indexPathForSelectedRow else { return nil }
        return tableView?.cellForRow(at: indexPath)
    }
}

// Opens the license page in a new tab
class LicenseAndAcknowledgementsSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .AppSettingsLicenses, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        return URL(string: "\(InternalURL.baseUrl)/\(AboutLicenseHandler.path)")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.ViewLicenses, attributes: EnvironmentHelper.shared.getAttributes())
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

// Opens about:rights page in the content view controller
class YourRightsSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .AppSettingsYourRights, attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        return URL(string: "https://neeva.co/terms")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.ViewTerms, attributes: EnvironmentHelper.shared.getAttributes())
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

// Opens the on-boarding screen again
class ShowIntroductionSetting: Setting {
    let profile: Profile

    override var accessibilityIdentifier: String? { return "ShowTour" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        super.init(title: NSAttributedString(string: NSLocalizedString("Show Tour", comment: "Show the on-boarding screen again from the settings"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.ViewShowTour, attributes: EnvironmentHelper.shared.getAttributes())
        navigationController?.dismiss(animated: true, completion: {
            BrowserViewController.foregroundBVC().presentIntroViewController(true)
        })
    }
}

class SendFeedbackSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .AppSettingsSendFeedback, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return URL(string: "https://input.neeva.co/feedback/fxios/\(appVersion)")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        // TODO: capture screenshot before opening settings? or perhaps remove this option entirely?
        navigationController?.pushViewController(SendFeedbackPanel(screenshot: nil, url: nil, onOpenURL: delegate!.settingsOpenURLInNewNonPrivateTab(_:)), animated: true)
    }
}

// Opens the SUMO page in a new tab
class OpenSupportPageSetting: Setting {
    init(delegate: SettingsDelegate?) {
        super.init(title: NSAttributedString(string: .AppSettingsHelp, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]),
            delegate: delegate)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.ViewHelpCenter, attributes: EnvironmentHelper.shared.getAttributes())
        navigationController?.dismiss(animated: true) {
            self.delegate?.settingsOpenURLInNewTab(NeevaConstants.appHelpCenterURL)
        }
    }
}

class ContentBlockerSetting: Setting {
    let profile: Profile
    var tabManager: TabManager!
    override var accessoryView: UIImageView? { return disclosureIndicator }
    override var accessibilityIdentifier: String? { return "TrackingProtection" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        self.tabManager = settings.tabManager
        super.init(title: NSAttributedString(string: Strings.SettingsTrackingProtectionSectionName, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.ViewTrackingProtection, attributes: EnvironmentHelper.shared.getAttributes())
        let viewController = ContentBlockerSettingViewController()
        viewController.profile = profile
        viewController.tabManager = tabManager
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class ClearPrivateDataSetting: Setting {
    let profile: Profile
    var tabManager: TabManager!

    override var accessoryView: UIImageView? { return disclosureIndicator }

    override var accessibilityIdentifier: String? { return "ClearPrivateData" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        self.tabManager = settings.tabManager

        let clearTitle = Strings.SettingsDataManagementSectionName
        super.init(title: NSAttributedString(string: clearTitle, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.ViewDataManagement, attributes: EnvironmentHelper.shared.getAttributes())
        let viewController = ClearPrivateDataTableViewController()
        viewController.profile = profile
        viewController.tabManager = tabManager
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class PrivacyPolicySetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .AppSettingsPrivacyPolicy, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL { NeevaConstants.appPrivacyURL }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.ViewPrivacyPolicy, attributes: EnvironmentHelper.shared.getAttributes())
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

fileprivate func getDisclosureIndicator() -> UIImageView {
    let disclosureIndicator = UIImageView()
    disclosureIndicator.image = UIImage(named: "menu-Disclosure")?.withRenderingMode(.alwaysTemplate)
    disclosureIndicator.tintColor = UIColor.theme.tableView.accessoryViewTint
    disclosureIndicator.sizeToFit()
    return disclosureIndicator
}

@available(iOS 12.0, *)
class SiriPageSetting: Setting {
    let profile: Profile

    override var accessoryView: UIImageView? { return disclosureIndicator }

    override var accessibilityIdentifier: String? { return "SiriSettings" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile

        super.init(title: NSAttributedString(string: Strings.SettingsSiriSectionName, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = SiriSettingsViewController()
        viewController.profile = profile
        navigationController?.pushViewController(viewController, animated: true)
    }
}

@available(iOS 14.0, *)
class DefaultBrowserSetting: Setting {
    let profile: Profile

    override var accessoryView: UIImageView? { return disclosureIndicator }

    override var accessibilityIdentifier: String? { return "DefaultBrowserSettings" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        
        super.init(title: NSAttributedString(string: "Default Browser", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowActionAccessory]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.SettingDefaultBrowser, attributes: EnvironmentHelper.shared.getAttributes())
        let viewController = DefaultBrowserSettingViewController()
        viewController.profile = profile
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class OpenWithSetting: Setting {
    let profile: Profile

    override var accessoryView: UIImageView? { return disclosureIndicator }

    override var accessibilityIdentifier: String? { return "OpenWith.Setting" }

    override var status: NSAttributedString {
        guard let provider = Defaults[.mailToOption], provider != "mailto:" else {
            return NSAttributedString(string: "")
        }
        if let path = Bundle.main.path(forResource: "MailSchemes", ofType: "plist"), let dictRoot = NSArray(contentsOfFile: path) {
            let mailProvider = dictRoot.compactMap({$0 as? NSDictionary }).first { (dict) -> Bool in
                return (dict["scheme"] as? String) == provider
            }
            return NSAttributedString(string: (mailProvider?["name"] as? String) ?? "")
        }
        return NSAttributedString(string: "")
    }

    override var style: UITableViewCell.CellStyle { return .value1 }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile

        super.init(title: NSAttributedString(string: Strings.SettingsOpenWithSectionName, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = OpenWithSettingsViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// Sign out from Neeva account
class SignOutSetting: Setting{
    init(delegate: SettingsDelegate?) {
        super.init(title: NSAttributedString(string: .AppNeevaSettingsSearch, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText]),
            delegate: delegate)
    }

    override var title: NSAttributedString? {
        return NSAttributedString(string: "Sign out", attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        ClientLogger.shared.logCounter(.SettingSignout, attributes: EnvironmentHelper.shared.getAttributes())
        if NeevaUserInfo.shared.hasLoginCookie() {
            NeevaUserInfo.shared.clearCache()
            NeevaUserInfo.shared.deleteLoginCookie()
            navigationController?.loadView()
        }
    }

}

