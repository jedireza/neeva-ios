// Copyright Neeva. All rights reserved.

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
    func presentAsPopover<Content: View>(
        isPresented: Binding<Bool>,
        backgroundColor: UIColor? = nil,
        arrowDirections: UIPopoverArrowDirection? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        background(
            // negative padding to counteract system padding
            Popover(
                isPresented: isPresented, arrowDirections: arrowDirections,
                content: content()
                    .padding(.vertical, -6.5)
                    .environment(\.inPopover, true),
                backgroundColor: backgroundColor, onDismiss: onDismiss)
        )
    }
}

private struct Popover<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let arrowDirections: UIPopoverArrowDirection?
    let content: Content
    let backgroundColor: UIColor?
    let onDismiss: (() -> Void)?

    class ViewController: UIViewController {
        var onDismiss: (() -> Void)?
        var presentee: Host? {
            didSet {
                if let presentee = presentee {
                    if let view = viewIfLoaded, view.window != nil {
                        present(presentee, animated: true)
                    }
                } else if let presentee = self.presentedViewController {
                    presentee.dismiss(animated: true) { [self] in
                        self.onDismiss?()
                    }
                }
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            DispatchQueue.main.async { [self] in
                if let presentee = presentee, presentedViewController == nil {
                    present(presentee, animated: true)
                }
            }
        }

        override func viewDidDisappear(_ animated: Bool) {
            presentee = nil
            super.viewDidDisappear(animated)
        }
    }

    class Host: UIHostingController<Content>, UIPopoverPresentationControllerDelegate {
        @Binding var isPresented: Bool
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
            // The two subviews of the container view at this point are _UIPopoverDimmingView and _UICutoutShadowView
            controller.containerView?.subviews.first(where: {
                String(cString: object_getClassName($0)).lowercased().contains("dimming")
            })?.backgroundColor = .ui.backdrop
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            isPresented = false
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            UIView.performWithoutAnimation { [self] in
                preferredContentSize = sizeThatFits(in: view.intrinsicContentSize)
            }
        }

        // Returning None here makes sure that the Popover is actually presented as a Popover and
        // not as a full-screen modal, which is the default on compact device classes.
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
        vc.onDismiss = onDismiss
        if let presentee = vc.presentee {
            presentee.rootView = content
            if !isPresented {
                vc.presentee = nil
            }
        } else if isPresented {
            let host = Host(rootView: content, isPresented: $isPresented)
            host.view.sizeToFit()
            host.modalPresentationStyle = .popover
            host.popoverPresentationController?.delegate = host
            host.popoverPresentationController?.sourceView = vc.view
            if let arrowDirections = arrowDirections {
                host.popoverPresentationController?.permittedArrowDirections = arrowDirections
            }
            vc.presentee = host
        }

        if let presentee = vc.presentee {
            presentee.preferredContentSize = presentee.sizeThatFits(
                in: presentee.view.intrinsicContentSize)
            presentee.view.backgroundColor = backgroundColor
        }
    }
}

extension EnvironmentValues {
    private struct InPopoverKey: EnvironmentKey {
        static let defaultValue = false
    }
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
                        ForEach(0..<count) { _ in
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
