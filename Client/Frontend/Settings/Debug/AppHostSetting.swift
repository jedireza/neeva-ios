// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct AppHostSetting: View {
    @Default(.neevaHost) var appHost

    @State var viewRef: UIView?

    var body: some View {
        HStack {
            Text(verbatim: "appHost")
                .font(.system(.body, design: .monospaced))
                + Text(verbatim: ": ")
                + Text(NeevaConstants.appHost)
                .font(.system(.body, design: .monospaced))

            Spacer()

            Button(String("Change")) {
                let alert = UIAlertController(
                    title: "Enter custom Neeva server", message: "Default is neeva.com",
                    preferredStyle: .alert)
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

                    tf.addAction(
                        UIAction { _ in
                            saveAction.isEnabled = tf.hasText
                        }, for: .editingChanged)

                    tf.addAction(
                        UIAction { _ in
                            saveAction.accessibilityActivate()
                        }, for: .primaryActionTriggered)
                }
                viewRef!.window!.windowScene!.frontViewController!
                    .present(alert, animated: true, completion: nil)
            }.uiViewRef($viewRef)
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
