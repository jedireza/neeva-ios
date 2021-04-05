import Foundation
import Shared
import Intents
import IntentsUI

class DefaultBrowserSettingViewController: SettingsTableViewController {
    let prefs: Prefs

    init(prefs: Prefs){
        self.prefs = prefs
        super.init(style: .grouped)

        self.title = "Default Browser"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func generateSettings() -> [SettingSection] {
        let setting = DefaultBrowserOpenSetting()
        let section = SettingSection(title:NSAttributedString(string: String.DefaultBrowserCardDescription), children: [setting], paragraphTitle: true)
        return [section]
    }
}

class DefaultBrowserOpenSetting: Setting {
    override var accessibilityIdentifier: String? { return String.DefaultBrowserMenuItem }

    init() {
        super.init(title: NSAttributedString(string: String.DefaultBrowserMenuItem),isLinkStyle: true)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }

}
