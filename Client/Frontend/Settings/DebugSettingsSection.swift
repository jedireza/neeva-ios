// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

struct DebugSettingsSection: View {
    @Environment(\.onOpenURL) var openURL
    @Default(.neevaHost) var appHost

    @State var legacySettingsModal = ModalState()

    var body: some View {
        Group {
            DecorativeSection {
                NavigationLinkButton("Legacy Settings", style: .modal, action: { legacySettingsModal.present() })
                    .modal(state: $legacySettingsModal) {
                        LegacySettingsView()
                    }
            }
            SwiftUI.Section(header: Text("Debug — Neeva")) {
                NavigationLink("Feature Flags", destination: FeatureFlagSettingsView().navigationTitle("Feature Flags"))
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

                NavigationLinkButton("Neeva Admin") {
                    openURL(NeevaConstants.appHomeURL / "admin")
                }
            }
            SwiftUI.Section(header: Text("Debug — Databases")) {
                Button("Copy Databases to App Container") {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    do {
                        let log = Logger.syncLogger
                        try BrowserViewController.foregroundBVC().profile.files.copyMatching(fromRelativeDirectory: "", toAbsoluteDirectory: documentsPath) { file in
                            log.debug("Matcher: \(file)")
                            return file.hasPrefix("browser.") || file.hasPrefix("logins.") || file.hasPrefix("metadata.")
                        }
                    } catch {
                        print("Couldn't export browser data: \(error).")
                    }
                }
                Button("Copy Log Files to App Container") {
                    Logger.copyPreviousLogsToDocuments()
                }
                Button("Delete Exported Databases") {
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
                Button("Simulate Slow Database Operations") {
                    debugSimulateSlowDBOperations.toggle()
                }
            }
            DecorativeSection {
                Button("Force Crash App") {
                    Sentry.shared.crash()
                }.accentColor(.red)
            }
        }
        .listRowBackground(Color.red.opacity(0.2))
    }
}

struct LegacySettingsView: ViewControllerWrapper {
    func makeUIViewController(context: Context) -> some UIViewController {
        let settings = AppSettingsTableViewController()
        let bvc = BrowserViewController.foregroundBVC()
        settings.profile = bvc.profile
        settings.tabManager = bvc.tabManager
        settings.settingsDelegate = bvc

        let controller = ThemedNavigationController(rootViewController: settings)
        controller.presentingModalViewControllerDelegate = bvc
        return controller
    }
    func updateUIViewController(_ settings: ViewController, context: Context) {}
}

struct DebugSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            DebugSettingsSection()
        }
    }
}
