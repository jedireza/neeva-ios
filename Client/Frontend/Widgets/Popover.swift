// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension View {
    /// Like `.popover()` except that it works on iPhones too!
    /// Specifically, `.popover()` acts like `.sheet()` when `horizontalSizeClass` is `.compact`,
    /// whereas this modifier forces the presented content to always be displayed inside a popover.
    ///
    /// This does not block touches on SwiftUI views displayed behind the popover’s backdrop.
    /// Once more of the UI is ported to SwiftUI, this should probably use a `PreferenceKey` to
    /// manually disable hit testing on the entire parent SwiftUI tree when a popover is presented.
    ///
    /// - Warning: ⚠️ Custom `@Environment` and `@EnvironmentObject` values are not carried into the content of the popover. You must manually specify them again in your content if you want them to be available.
    /// - Parameters:
    ///   - isPresented: Set this binding to `true` to present the popover, or `false` to dismiss it. The modifier will set the binding to `false` when the user manually dismisses the popover.
    ///   - backgroundColor: The color to display beneath the SwiftUI view in the popover. SwiftUI struggles to apply a background color correctly here.
    ///   - arrowDirections: The directions the popover arrow is allowed to point
    ///   - dismissOnTransition: Whether to dismiss the popover when changing window size/orientation.
    ///   - onDismiss: Called after the popover view has been dismissed. Useful for delaying actions that may present a view controller to avoid issues.
    ///   - content: The content to display in the popover.
    func presentAsPopover<Content: View>(
        isPresented: Binding<Bool>,
        backgroundColor: UIColor? = nil,
        arrowDirections: UIPopoverArrowDirection? = nil,
        dismissOnTransition: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        background(
            Popover(
                isPresented: isPresented,
                arrowDirections: arrowDirections,
                backgroundColor: backgroundColor,
                dismissOnTransition: dismissOnTransition,
                onDismiss: onDismiss
            ) {
                content()
                    // negative padding to counteract system popover padding
                    .padding(.vertical, -6.5)
                    .environment(\.inPopover, true)
            }
        )
    }
}

/// `Popover` wraps a view controller that handles presenting and dismissing the actual popover
struct Popover<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let arrowDirections: UIPopoverArrowDirection?
    let backgroundColor: UIColor?
    let dismissOnTransition: Bool
    let onDismiss: (() -> Void)?
    let content: () -> Content

    /// This view controller is invisible, and it displays the popover pointing at its bounds..
    class ViewController: UIViewController {
        var dismissOnTransition = false

        /// The currently presented view controller. Set to `nil` to dismiss.
        var presentee: Host? {
            didSet {
                if let presentee = presentee {
                    if let view = viewIfLoaded, view.window != nil {
                        // Dismiss any presented view controller before presenting the popover. (this can happen when
                        // a popover is already presented like tapping another bar button) Ideally, we should block touches behind
                        // the popover backdrop once we have one SwiftUI. More detail in presentAsPopover comment
                        dismiss(animated: false, completion: nil)
                        present(presentee, animated: true)
                    }
                } else if let presentee = self.presentedViewController, presentee == oldValue {
                    presentee.dismiss(animated: true)
                }
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Workaround for bugs that happen when passing a binding with an initial value of true.
            DispatchQueue.main.async { [self] in
                if let presentee = presentee, presentedViewController == nil {
                    present(presentee, animated: true)
                }
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            // Dismiss the popover when removing this view controller.
            presentee = nil
            super.viewWillDisappear(animated)
        }

        override func viewWillTransition(
            to size: CGSize,
            with coordinator: UIViewControllerTransitionCoordinator
        ) {
            super.viewWillTransition(to: size, with: coordinator)
            presentee = nil
        }
    }

    /// This hosting controller is displayed inside the popover, and renders the user-specified content.
    class Host: UIHostingController<Content>, UIPopoverPresentationControllerDelegate {
        @Binding var isPresented: Bool
        var onDismiss: (() -> Void)?

        init(rootView: Content, isPresented: Binding<Bool>) {
            self._isPresented = isPresented
            super.init(rootView: rootView)
        }

        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard let controller = presentationController else { return }
            // The two subviews of the container view at this point are _UIPopoverDimmingView and _UICutoutShadowView.
            // Apply a custom background color here because — at least on iPhone — the default is `UIColor.clear`.
            controller.containerView?.subviews.first(where: {
                String(cString: object_getClassName($0)).lowercased().contains("dimming")
            })?.backgroundColor = .ui.backdrop
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            // Handle interactive dismissal of the popover (triggered by tapping outside its bounds)
            onDismiss?()
            isPresented = false
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Resizes the popover to fit its content.
            UIView.performWithoutAnimation { [self] in
                preferredContentSize = sizeThatFits(in: view.intrinsicContentSize)
            }
        }

        // Returning `.none` here makes sure that the Popover is actually presented as a popover
        // and not as a full-screen modal, which is the default on compact device classes.
        func adaptivePresentationStyle(
            for controller: UIPresentationController, traitCollection: UITraitCollection
        ) -> UIModalPresentationStyle {
            return .none
        }
    }

    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }

    func updateUIViewController(_ vc: ViewController, context: Context) {
        vc.dismissOnTransition = dismissOnTransition
        if let presentee = vc.presentee {
            // If the popover is visible, update its content
            presentee.rootView = content()
            // …and hide it if necessary
            if !isPresented {
                vc.presentee = nil
            }
        } else if isPresented {
            // Create and present a new popover
            let host = Host(rootView: content(), isPresented: $isPresented)
            host.view.sizeToFit()
            host.modalPresentationStyle = .popover
            host.popoverPresentationController?.delegate = host
            host.popoverPresentationController?.sourceView = vc.view
            if let arrowDirections = arrowDirections {
                host.popoverPresentationController?.permittedArrowDirections = arrowDirections
            }
            vc.presentee = host
        }

        // Update the displayed popover. This is different from the above if-let
        // because it handles the case where the popover was just presented too.
        if let presentee = vc.presentee {
            presentee.preferredContentSize = presentee.sizeThatFits(
                in: presentee.view.intrinsicContentSize)
            presentee.view.backgroundColor = backgroundColor
            presentee.onDismiss = onDismiss
        }
    }
}

extension EnvironmentValues {
    private struct InPopoverKey: EnvironmentKey {
        static let defaultValue = false
    }
    /// True when inside of a `presentAsPopover`-based popover.
    fileprivate(set) var inPopover: Bool {
        get { self[InPopoverKey.self] }
        set { self[InPopoverKey.self] = newValue }
    }
}

struct Popover_Previews: PreviewProvider {
    struct TestView: View {
        @State var isPresented = false
        @State var count = 1
        var body: some View {
            Button("Popover") { isPresented = true }
                .presentAsPopover(isPresented: $isPresented) {
                    VStack {
                        ForEach(0..<count, id: \.self) { _ in
                            Text("Hello, world!")
                                .padding()
                        }
                        Button("+1") { count += 1 }.padding()
                    }
                }
        }
    }
    static var previews: some View {
        TestView()
    }
}
