// Copyright Neeva. All rights reserved.

import Combine
import SwiftUI
import UIKit

struct KeyboardListener: ViewModifier {
    @State var currentHeight: CGFloat = 0 {
        didSet {
            keyboardHeightChanged(currentHeight)
        }
    }
    let adapt: Bool
    var keyboardHeightChanged: (CGFloat) -> Void

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(y: adapt ? -1 : 0)
                .onAppear(perform: {
                    NotificationCenter.Publisher(
                        center: NotificationCenter.default,
                        name: UIResponder.keyboardWillShowNotification
                    )
                    .merge(
                        with: NotificationCenter.Publisher(
                            center: NotificationCenter.default,
                            name: UIResponder.keyboardWillChangeFrameNotification)
                    )
                    .compactMap { notification in
                        withAnimation(.easeOut(duration: 0.16)) {
                            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                as? CGRect
                        }
                    }
                    .map { rect in
                        rect.height - geometry.safeAreaInsets.bottom
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))

                    NotificationCenter.Publisher(
                        center: NotificationCenter.default,
                        name: UIResponder.keyboardWillHideNotification
                    )
                    .compactMap { notification in
                        CGFloat.zero
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                })
        }
    }
}

extension View {
    /// - Parameters:
    ///   - adapts: If `true`, adjust the view to move with the keyboard
    func keyboardListener(adapt: Bool = true, keyboardHeightChanged: @escaping (CGFloat) -> Void)
        -> some View
    {
        return modifier(
            KeyboardListener(adapt: adapt, keyboardHeightChanged: keyboardHeightChanged))
    }
}
