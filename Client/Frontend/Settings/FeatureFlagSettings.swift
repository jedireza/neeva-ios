//
//  FeatureFlagSettings.swift
//  Client
//
//  Created by Jed Fox on 5/19/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Shared

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
    var body: some View {
        List(FeatureFlag.allCases, id: \.rawValue) { flag in
            Toggle(flag.rawValue, isOn: Binding(
                    get: { FeatureFlag[flag] },
                    set: { FeatureFlag[flag] = $0 }
            ))
        }.listStyle(InsetGroupedListStyle())
    }
}

struct FeatureFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeatureFlagSettingsView()
                .navigationTitle("Feature Flags")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
