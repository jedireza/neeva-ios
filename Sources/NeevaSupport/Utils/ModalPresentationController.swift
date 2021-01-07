//
//  ModalPresentationController.swift
//  
//
//  Source: https://stackoverflow.com/a/61239704/5244995
//  + https://stackoverflow.com/q/56615408#comment111486363_61239704
//

import SwiftUI

struct ModalView<T: View>: UIViewControllerRepresentable {
    let view: T
    let isModal: Bool
    let onDismissalAttempt: (()->())?

    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: view)
    }

    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {
        context.coordinator.modalView = self
        uiViewController.rootView = view
        uiViewController.parent?.presentationController?.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var modalView: ModalView

        init(_ modalView: ModalView) {
            self.modalView = modalView
        }

        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            !modalView.isModal
        }

        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            modalView.onDismissalAttempt?()
        }
    }
}

extension View {
    func presentation(isModal: Bool, onDismissalAttempt: (()->())? = nil) -> some View {
        GeometryReader { geom in
            ModalView(view: self.padding(geom.safeAreaInsets), isModal: isModal, onDismissalAttempt: onDismissalAttempt)
        }.edgesIgnoringSafeArea(.all)
    }
}
