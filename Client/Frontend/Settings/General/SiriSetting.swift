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

    @State var shortcutSheetVisible = false

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
                NavigationLinkButton("Open New Tab", style: isLoading ? .loading : .modal) { shortcutSheetVisible = true }
                    .sheet(isPresented: $shortcutSheetVisible) {
                        switch shortcutManager.shortcut {
                        case .loading: EmptyView()
                        case .notFound:
                            AddToSiriView(
                                manager: shortcutManager,
                                isPresented: $shortcutSheetVisible
                            ).ignoresSafeArea()
                        case .found(let shortcut):
                            EditSiriView(
                                manager: shortcutManager,
                                shortcut: shortcut,
                                isPresented: $shortcutSheetVisible
                            ).ignoresSafeArea()
                        }
                    }.disabled(isLoading)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Siri Shortcuts")
    }
}

// TODO: these don’t support swiping down inside the VC to dismiss.
// maybe we need to turn them into invisible views placed in .background()
// that present a the INUI* VC using UIKit?
struct AddToSiriView: UIViewControllerRepresentable {
    let manager: SiriShortcutManager
    @Binding var isPresented: Bool

    class Coordinator: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
        var manager: SiriShortcutManager
        var isPresented: Binding<Bool>

        init(manager: SiriShortcutManager, isPresented: Binding<Bool>) {
            self.manager = manager
            self.isPresented = isPresented
        }

        func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
            manager.reload()
            isPresented.wrappedValue = false
        }

        func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
            isPresented.wrappedValue = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager, isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let activity = SiriShortcuts().getActivity(for: manager.activityType)!
        let shortcut = INShortcut(userActivity: activity)
        let addViewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        addViewController.modalPresentationStyle = .formSheet
        addViewController.delegate = context.coordinator
        return addViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.manager = manager
        context.coordinator.isPresented = $isPresented
    }
}

struct EditSiriView: UIViewControllerRepresentable {
    let manager: SiriShortcutManager
    let shortcut: INVoiceShortcut
    @Binding var isPresented: Bool

    class Coordinator: NSObject, INUIEditVoiceShortcutViewControllerDelegate {
        var manager: SiriShortcutManager
        var isPresented: Binding<Bool>

        init(manager: SiriShortcutManager, isPresented: Binding<Bool>) {
            self.manager = manager
            self.isPresented = isPresented
        }

        func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
            manager.reload()
            isPresented.wrappedValue = false
        }

        func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
            manager.reload()
            isPresented.wrappedValue = false
        }

        func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
            isPresented.wrappedValue = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager, isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let editViewController = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
        editViewController.modalPresentationStyle = .formSheet
        editViewController.delegate = context.coordinator
        return editViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.manager = manager
        context.coordinator.isPresented = $isPresented
    }
}

struct SiriSetting_Previews: PreviewProvider {
    static var previews: some View {
        SiriSetting()
    }
}
