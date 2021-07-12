// Copyright Neeva. All rights reserved.

import SwiftUI

struct MailAppSetting: View {
    static func canOpenMailScheme(_ scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    static var mailProviderSource: [(name: String, scheme: String)] = {
        if let path = Bundle.main.path(forResource: "MailSchemes", ofType: "plist"), let dictRoot = NSArray(contentsOfFile: path) {
            return dictRoot.map { dict in
                let nsDict = dict as! NSDictionary
                return (name: nsDict["name"] as! String, scheme: nsDict["scheme"] as! String)
            }
        }
        return []
    }()

    @Binding var mailToOption: String?

    var body: some View {
        List {
            SwiftUI.Section(header: Text("Open mail links with")) {
                ForEach(Self.mailProviderSource, id: \.scheme) { (name, scheme) in
                    let isSelected = scheme == mailToOption
                    let disabled = !Self.canOpenMailScheme(scheme)
                    HStack {
                        Button(action: { mailToOption = scheme }) {
                            if disabled {
                                Text(name)
                            } else {
                                Text(name).foregroundColor(.label)
                            }
                        }
                            .disabled(disabled)
                            .accessibilityAddTraits(isSelected ? .isSelected : [])
                        if isSelected {
                            Spacer()
                            Image(systemSymbol: .checkmark)
                                .foregroundColor(.blue)
                                .accessibilityHidden(true)
                        }
                    }.accessibilityElement(children: .combine)
                }
            }
        }
        .applySettingsListStyle()
        .navigationTitle("Mail App")
    }
}

struct MailAppSetting_Previews: PreviewProvider {
    static var previews: some View {
        MailAppSetting(mailToOption: .constant("mailto:"))
    }
}
