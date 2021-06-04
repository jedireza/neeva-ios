//
//  SiriSetting.swift
//  Client
//
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import IntentsUI
import Shared

struct SiriSetting: View {
    @ObservedObject var shortcutManager = SiriShortcutManager(.openURL)

    @State var shortcutModal = ModalState()

    var isLoading: Bool {
        if case .loading = shortcutManager.shortcut {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        List {
            DecorativeSection(footer: "Use Siri shortcuts to quickly open Neeva via Siri") {
                let link = NavigationLinkButton("Open New Tab", style: isLoading ? .loading : .modal) { shortcutModal.present() }
                    .disabled(isLoading)
                switch shortcutManager.shortcut {
                case .loading: link
                case .notFound:
                    link.modal(state: $shortcutModal) {
                        AddToSiriView(
                            manager: shortcutManager,
                            modalState: $shortcutModal
                        )
                    }
                case .found(let shortcut):
                    link.modal(state: $shortcutModal) {
                        EditSiriView(
                            manager: shortcutManager,
                            shortcut: shortcut,
                            modalState: $shortcutModal
                        )
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Siri Shortcuts")
    }
}

struct AddToSiriView: ViewControllerWrapper {
    let manager: SiriShortcutManager
    @Binding var modalState: ModalState

    class Coordinator: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
        var manager: SiriShortcutManager
        @Binding var modalState: ModalState

        init(manager: SiriShortcutManager, modalState: Binding<ModalState>) {
            self.manager = manager
            self._modalState = modalState
        }

        func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
            manager.reload()
            modalState.dismiss()
        }

        func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
            modalState.dismiss()
        }

        func updateSheetBinding(to newValue: Binding<ModalState>) {
            _modalState = newValue
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager, modalState: _modalState)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let activity = SiriShortcuts().getActivity(for: manager.activityType)!
        let shortcut = INShortcut(userActivity: activity)
        let addViewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        addViewController.modalPresentationStyle = .formSheet
        addViewController.delegate = context.coordinator
        return addViewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        context.coordinator.manager = manager
        context.coordinator.updateSheetBinding(to: _modalState)
    }
}

struct EditSiriView: ViewControllerWrapper {
    let manager: SiriShortcutManager
    let shortcut: INVoiceShortcut
    @Binding var modalState: ModalState

    class Coordinator: NSObject, INUIEditVoiceShortcutViewControllerDelegate {
        var manager: SiriShortcutManager
        @Binding var modalState: ModalState

        init(manager: SiriShortcutManager, modalState: Binding<ModalState>) {
            self.manager = manager
            self._modalState = modalState
        }

        func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
            manager.reload()
            modalState.dismiss()
        }

        func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
            manager.reload()
            modalState.dismiss()
        }

        func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
            modalState.dismiss()
        }

        func updateSheetBinding(to newValue: Binding<ModalState>) {
            _modalState = newValue
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager, modalState: _modalState)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let editViewController = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
        editViewController.modalPresentationStyle = .formSheet
        editViewController.delegate = context.coordinator
        return editViewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        context.coordinator.manager = manager
        context.coordinator.updateSheetBinding(to: _modalState)
    }
}

struct SiriSetting_Previews: PreviewProvider {
    static var previews: some View {
        SiriSetting()
    }
}
