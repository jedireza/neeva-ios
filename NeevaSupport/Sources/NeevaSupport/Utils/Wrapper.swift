//
//  Wrapper.swift
//  
//
//  Created by Jed Fox on 1/18/21.
//

import SwiftUI

/// A wrapper view used to break out of SwiftUI’s “magical” default behaviors in certain contexts
/// For example, this removes the default text styles in list section headers.
struct Wrapper<Content: View>: UIViewControllerRepresentable {
    var content: () -> Content

    /// - Parameter content: The content to display
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = .clear
        vc.view.isOpaque = false
        return vc
    }
    func updateUIViewController(_ vc: UIHostingController<Content>, context: Context) {
        vc.rootView = content()
    }
}
