// Copyright © Neeva. All rights reserved.

import SwiftUI
import Introspect

/**
 * # Why do we need `ViewControllerWrapper`?
 *
 * SwiftUI allows you to use `UIViewControllerRepresentable` to embed an arbitrary subclass of `UIViewController`
 * in a SwiftUI view hierarchy. However, this is suboptimal when used with a modifier like `sheet(isPresented:)` for a couple of reasons:
 * 1. SwiftUI will size the view controller to keep it inside the safe area, which we don’t actually want since the view controllers are
 *   perfectly capable of handling that themselves. This also leaves blank space at the bottom of the screen, which looks bad.
 * 2. The presented view controller doesn’t know that it’s being modally presented. This means that some things won’t work properly,
 *   such as swiping down to dismiss an `INUIEditVoiceShortcutViewController`.
 *
 * To solve these problems, we use a little magic to directly present the view controller on top of the current `UIViewController`.
 */

// this is used to obscure the current presentation status from other code
// since we don’t have a way to know whether the modal has been manually dismissed
public struct ModalState {
    public init() {}

    /// Present the view controller if it is not already presented
    public mutating func present() { desiredAction = .present }
    /// Dismiss the view controller if it is presented.
    public mutating func dismiss() { desiredAction = .dismiss }

    fileprivate var desiredAction: DesiredAction?
    fileprivate enum DesiredAction {
        case present
        case dismiss
    }
}

extension View {
    /// Usage:
    /// ```
    /// @State var modal = ModalState()
    ///
    /// Button("...") { modal.present() }
    ///     .modal(state: $modal) {
    ///         MyViewControllerWrapper(...)
    ///     }
    /// ```
    public func modal<Content: ViewControllerWrapper>(state: Binding<ModalState>, content: () -> Content) -> some View {
        overlay(ViewControllerWrapper_Presenter(state: state, wrapper: content()))
    }
}

/// This is designed to be compatible with `UIViewControllerRepresentable`.
/// You can implement this protocol’s methods in the same way as you would with that protocol.
/// We need this protocol because we don’t have access to `UIViewControllerRepresentableContext`’s initializers
/// and because we don’t have access to `transaction` and `environment`.
public protocol ViewControllerWrapper {
    associatedtype ViewController : UIViewController
    associatedtype Coordinator = Void

    typealias Context = ViewControllerWrapperContext<Self>
    func makeUIViewController(context: Context) -> ViewController
    func updateUIViewController(_ vc: ViewController, context: Context)

    /// Optional.
    static func dismantleUIViewController(_ vc: ViewController, coordinator: Coordinator)
    /// Optional.
    func makeCoordinator() -> Coordinator
}
extension ViewControllerWrapper {
    public static func dismantleUIViewController(_ vc: ViewController, coordinator: Coordinator) {}
}
extension ViewControllerWrapper where Coordinator == Void {
    public func makeCoordinator() {}
}

/// This is designed to match `UIViewRepresentableContext`, although it is currently missing `transaction` and
/// `environment` for technical reasons. Specifically, `transaction` and `environment` are only provided to
/// `UI{View,ViewController}Representable` instances. Since we don’t have direct access to these at the time
/// we run the relevant functions on the `ViewControllerWrapper` instance, we can’t be sure we’re supplying up-to-date values.
public struct ViewControllerWrapperContext<Wrapper: ViewControllerWrapper> {
    public let coordinator: Wrapper.Coordinator
    // currently unimplemented:
    // public let transaction: Transaction
    // public let environment: EnvironmentValues
}

// MARK: - Internals

/// I found that `introspectViewController` could not find a view controller, but this produced good results.
fileprivate func findViewController(in responder: UIResponder) -> UIViewController? {
    if let vc = responder as? UIViewController {
        return vc
    } else if let next = responder.next {
        return findViewController(in: next)
    } else {
        return nil
    }
}

/// The SwiftUI view that handles the actual present/dismiss logic
public struct ViewControllerWrapper_Presenter<Wrapper: ViewControllerWrapper>: View {
    @Binding var state: ModalState
    let wrapper: Wrapper

    /// This stores the presented view controller and the coordinator. Since both values are either present
    /// (when the view controller is being presented) or absent, we store them in a tuple instead of as separate optional properties.
    @State private var presentee: (Wrapper.ViewController, Wrapper.Coordinator)?

    public var body: some View {
        // Reference `state` in the view body to make sure this view gets re-rendered whenever the state changes
        let _ = state
        // use an EmptyView here because calling `introspect` on `self` results in an infinitely-nested view tree that crashes the app
        return EmptyView().frame(width: 0, height: 0).introspect(selector: { $0 }) { view in
            guard let vc = findViewController(in: view) else {
                // disabled because the view controller sometimes can’t be found, but I’ve found this to not impact performance.
                // print("**** UNEXPECTED FAILURE TO LOCATE VIEW CONTROLLER FOR LEGACY SHEET CONTAINING \(Delegate.Type.self)****")
                return
            }

            if let (presentee, coordinator) = presentee {
                wrapper.updateUIViewController(presentee, context: .init(coordinator: coordinator))

                if state.desiredAction == .dismiss {
                    vc.dismiss(animated: true, completion: nil)
                    // allow the view controller and coordinator to be freed now that they are no longer needed
                    self.presentee = nil
                    Wrapper.dismantleUIViewController(presentee, coordinator: coordinator)
                    state.desiredAction = nil
                } else if presentee.presentingViewController == nil {
                    // if this view has been re-rendered after the view controller was manually dismissed, set `presentee` to nil.
                    Wrapper.dismantleUIViewController(presentee, coordinator: coordinator)
                    self.presentee = nil
                }
            }

            if state.desiredAction == .present && self.presentee == nil {
                let coordinator = wrapper.makeCoordinator()
                let presentee = wrapper.makeUIViewController(context: .init(coordinator: coordinator))
                vc.present(presentee, animated: true, completion: nil)
                self.presentee = (presentee, coordinator)
                // reset the state to `nil` so that this code will be run if the view controller
                // is manually dismissed (which we don’t detect), then `state` is set to `.present`.
                state.desiredAction = nil
            }
        }.onDisappear {
            // manually tear down the view controller when this view is unmounted.
            // state will be thrown away, so we don’t need to worry about that.
            if let (presentee, coordinator) = presentee {
                Wrapper.dismantleUIViewController(presentee, coordinator: coordinator)
                presentee.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
