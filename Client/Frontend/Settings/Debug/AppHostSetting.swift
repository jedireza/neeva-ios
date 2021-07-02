// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

struct AppHostSetting: View {
    @Default(.neevaHost) var appHost

    var body: some View {
        HStack {
            Text("appHost")
                .font(.system(.body, design: .monospaced))
            + Text(": ")
            + Text(NeevaConstants.appHost)
                .font(.system(.body, design: .monospaced))

            Spacer()

            Button(action: {
                let alert = UIAlertController(title: "Enter custom Neeva server", message: "Default is neeva.com", preferredStyle: .alert)
                let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                    appHost = alert.textFields!.first!.text!
                }

                alert.addAction(saveAction)
                alert.addTextField { tf in
                    tf.placeholder = "Neeva server domain (required)"
                    tf.text = appHost
                    tf.keyboardType = .URL
                    tf.clearButtonMode = .always
                    tf.returnKeyType = .done

                    tf.addAction(UIAction { _ in
                        saveAction.isEnabled = tf.hasText
                    }, for: .editingChanged)

                    tf.addAction(UIAction { _ in
                        saveAction.accessibilityActivate()
                    }, for: .primaryActionTriggered)
                }
                UIApplication.shared.frontViewController.present(alert, animated: true, completion: nil)
            }) {
                Text("Change")
            }
        }.accessibilityElement(children: .combine)
    }
}

struct AppHostSetting_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            AppHostSetting()
        }
    }
}
