// Copyright Neeva. All rights reserved.

import SwiftUI

extension View {
    /// Get a reference to a `UIView` instance that has the same frame
    /// as the view to which this modifier is applied. Useful for, among other things,
    /// presenting a UIKit popover that points at a SwiftUI view.
    func uiViewRef(_ view: Binding<UIView?>) -> some View {
        background(ViewRef(view: view).allowsHitTesting(false))
    }
}

private struct ViewRef: UIViewRepresentable {
    @Binding var view: UIView?
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.isOpaque = false
        view.isUserInteractionEnabled = false
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if uiView != self.view {
                self.view = uiView
            }
        }
    }
}
