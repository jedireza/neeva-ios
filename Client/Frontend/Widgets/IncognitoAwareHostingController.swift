// Copyright Neeva. All rights reserved.

import SwiftUI

/// A `UIHostingController` subclass that automatically provides an appropriate value
/// for `EnvironmentValues.isIncognito` to the view it hosts.
class IncognitoAwareHostingController<Content: View>: UIHostingController<
    IncognitoAwareHostingController._Applicator<Content>
>, PrivateModeUI
{
    /// Initializes this hosting controller.
    ///
    /// In your initializer, provide an initial view by calling this initializer like so:
    /// ```
    /// super.init {
    ///   // view content that does not depend on self
    /// }
    /// ```
    /// or by calling `super.init()` and using `setRootView` to specify a view that depends on `self`.
    init(rootView: (() -> Content)? = nil) {
        super.init(
            rootView: _Applicator(
                content: rootView,
                isIncognito: SceneDelegate.getTabManager().isIncognito
            )
        )
    }

    /// Call `setRootView { /* view body */ }` to update the view displayed to the user.
    func setRootView(@ViewBuilder newContent: @escaping () -> Content) {
        rootView = _Applicator(content: newContent, isIncognito: rootView.isIncognito)
    }

    func applyUIMode(isPrivate: Bool) {
        rootView = _Applicator(content: rootView.content, isIncognito: isPrivate)
    }

    // can’t be fileprivate because the type of the generic on UIHostingController
    // is required to be at least as public as the hosting controller subclass itself.
    // swift-format-ignore: NoLeadingUnderscores
    struct _Applicator<Content: View>: View {
        fileprivate let content: (() -> Content)?
        fileprivate let isIncognito: Bool

        var body: some View {
            if let content = content {
                content()
                    .environment(\.isIncognito, isIncognito)
            }
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
