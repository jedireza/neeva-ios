/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SwiftUI

struct ViewControllerConsts {
    struct PreferredSize {
        static let IntroViewController = CGSize(width: 375, height: 667)
        static let UpdateViewController = CGSize(width: 375, height: 667)
        static let DBOnboardingViewController = CGSize(width: 624, height: 680)
    }
}

// From https://www.avanderlee.com/swiftui/integrating-swiftui-with-uikit/
extension UIViewController {
    /// Add a SwiftUI `View` as a child of the input `UIView`.
    /// - Parameters:
    ///   - swiftUIView: The SwiftUI `View` to add as a child.
    ///   - view: The `UIView` instance to which the view should be added.
    func addSubSwiftUIView<Content>(_ swiftUIView: Content, to containerView: UIView) where Content : View {
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear

        /// Add as a child of the current view controller.
        addChild(hostingController)

        /// Add the SwiftUI view to the view controller view hierarchy.
        containerView.addSubview(hostingController.view)

        /// Setup the contraints to update the SwiftUI view boundaries.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        /// Notify the hosting controller that it has been moved to the current view controller.
        hostingController.didMove(toParent: self)
    }
}
