//
//  Workarounds.swift
//  
//
//  Created by Jed Fox on 1/7/21.
//

import SwiftUI

// Source: https://github.com/sindresorhus/swiftui/discussions/7#discussioncomment-236510
extension View {
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

// The `openURL` environment key is not writable, so we need to roll our own.
extension EnvironmentValues {
    private struct OnOpenURLKey: EnvironmentKey {
        static var defaultValue: ((URL) -> ())? = nil
    }

    /// Provide this environment key to open URLs in an app other than Safari.
    public var onOpenURL: (URL) -> () {
        get { self[OnOpenURLKey] ?? { openURL($0) } }
        set { self[OnOpenURLKey] = newValue }
    }
}
