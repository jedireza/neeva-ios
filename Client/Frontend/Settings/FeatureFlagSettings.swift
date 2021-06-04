//
//  FeatureFlagSettings.swift
//  Client
//
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Shared
import Defaults

class FeatureFlagSetting: HiddenSetting {
    override var title: NSAttributedString? {
        NSAttributedString(string: "Debug: Feature Flags")
    }

    override var accessoryView: UIImageView? {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(named: "menu-Disclosure")?.withRenderingMode(.alwaysTemplate)
        disclosureIndicator.tintColor = UIColor.theme.tableView.accessoryViewTint
        disclosureIndicator.sizeToFit()
        return disclosureIndicator
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let vc = UIHostingController(rootView: FeatureFlagSettingsView())
        vc.navigationItem.title = "Feature Flags"
        navigationController?.pushViewController(vc, animated: true)
    }
}


struct FeatureFlagSettingsView: View {
    @Default(FeatureFlag.defaultsKey) var key
    var body: some View {
        List {
            DecorativeSection {
                // trigger updates when toggling
                let _ = key
                ForEach(FeatureFlag.allCases, id: \.rawValue) { flag in
                    Toggle(flag.rawValue, isOn: Binding(
                        get: { FeatureFlag[flag] },
                        set: { FeatureFlag[flag] = $0 }
                    )).toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
        }.listStyle(GroupedListStyle())
    }
}

struct FeatureFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeatureFlagSettingsView()
                .navigationTitle("Feature Flags")
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
