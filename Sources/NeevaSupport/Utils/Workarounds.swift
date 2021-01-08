//
//  Workarounds.swift
//  
//
//  Created by Jed Fox on 1/7/21.
//

import SwiftUI

extension View {
    // Source: https://github.com/sindresorhus/swiftui/discussions/7#discussioncomment-236510
    /// This allows multiple sheets on a single view, which `.sheet()` doesn't.o
    func additionalSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        background(
            EmptyView().sheet(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}
