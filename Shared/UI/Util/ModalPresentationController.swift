// Copyright Neeva. All rights reserved.
//
//  Source: https://stackoverflow.com/a/61239704/5244995
//  + https://stackoverflow.com/q/56615408#comment111486363_61239704
//

import SwiftUI

extension View {
    /// Prevent the user from swiping to dismiss the current sheet.
    /// - Warning: Do not pass `isModal: true` on the first render. If you want to do this, you must put the `presentation()`
    ///   modifier directly inside the `.sheet { ... }` modifier and not inside of your sheet content view’s `body`. I do not know why this limitation exists.
    ///   See [this old commit](https://github.com/neevaco/neeva-ios-support/blob/8c3989f968b794d9014b89ef90347ed6c6ebdda6/Sources/NeevaSupport/Spaces/EditSpaceView.swift#L12-L23) for an example of how to write a helper function to wrap a view for this use case.
    /// - Parameters:
    ///   - isModal: whether to prevent swiping to dismiss
    ///   - onDismissalAttempt: called if `isModal` is true and the user attempts to swipe to dismiss.
    ///   You can use this, for example, to present an action sheet that prompts them to confirm discarding changes.
    public func presentation(isModal: Bool, onDismissalAttempt: (()->())? = nil) -> some View {
        GeometryReader { geom in
            ModalView(view: self.padding(geom.safeAreaInsets), isModal: isModal, onDismissalAttempt: onDismissalAttempt)
        }.edgesIgnoringSafeArea(.all)
    }
}

fileprivate struct ModalView<T: View>: UIViewControllerRepresentable {
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
