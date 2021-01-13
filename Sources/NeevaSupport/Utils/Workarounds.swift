//
//  Workarounds.swift
//  
//
//  Created by Jed Fox on 1/7/21.
//

import SwiftUI

extension View {
    // Source: https://github.com/sindresorhus/swiftui/discussions/7#discussioncomment-236510
    /// This allows multiple sheets on a single view, which `.sheet()` doesn't.
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
    /// This allows multiple action sheets on a single view, which `.sheet()` doesn't.
    func additionalActionSheet(
        isPresented: Binding<Bool>,
        content: @escaping () -> ActionSheet
    ) -> some View {
        background(
            EmptyView().actionSheet(
                isPresented: isPresented,
                content: content
            )
        )
    }
}

extension EnvironmentValues {
    private struct OnOpenURLKey: EnvironmentKey {
        static var defaultValue: ((URL) -> ())? = nil
    }
    public var onOpenURL: (URL) -> () {
        get { self[OnOpenURLKey] ?? { openURL($0) } }
        set { self[OnOpenURLKey] = newValue }
    }
}
