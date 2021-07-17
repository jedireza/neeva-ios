// Copyright Neeva. All rights reserved.

import SwiftUI

struct ThrobbingHighlightBorder: ViewModifier {
    // animation effect
    @State var isAtMaxScale = false
    @Environment(\.colorScheme) private var colorScheme

    private let animation = Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
    var highlight: Color = Color.blue
    var staticColorMode: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(highlight, lineWidth: 4)
                    .padding([.horizontal, .vertical], -8)
                    .opacity(Double(2 - (isAtMaxScale ? 1.5 : 1.0)))
                    .scaleEffect(isAtMaxScale ? 1.05 : 1.0)
                    .colorScheme(staticColorMode ? .light : colorScheme)
                    .onAppear() {
                        withAnimation(self.animation, {
                            self.isAtMaxScale.toggle()
                        })
                    }
            )
    }
}

public extension View {
    func throbbingHighlightBorderStyle(highlight: Color, staticColorMode: Bool? = false) -> some View {
        self.modifier(ThrobbingHighlightBorder(highlight: highlight, staticColorMode: staticColorMode!))
    }
}

extension View {
    func clipped(padding: CGFloat) -> some View {
        self
            .padding(padding)
            .clipped()
            .padding(-padding)
    }

    /// Inspired by React’s `useEffect` hook, this modifier calls `perform(deps)` both `onAppear` and whenever `deps` changes.
    func useEffect<T: Equatable>(deps: T, perform updater: @escaping (T) -> ()) -> some View {
        self.onChange(of: deps, perform: updater)
            .onAppear { updater(deps) }
    }
    /// Inspired by React’s `useEffect` hook, this modifier calls `perform(deps)` both `onAppear` and whenever `deps` changes.
    func useEffect<T0: Equatable, T1: Equatable>(deps zero: T0, _ one: T1, perform updater: @escaping (T0, T1) -> ()) -> some View {
        self.onChange(of: Pair(zero: zero, one: one)) { updater($0.zero, $0.one) }
            .onAppear { updater(zero, one) }
    }
    // TODO: add conformances for larger tuples as necessary
}

fileprivate struct Pair<T0: Equatable, T1: Equatable>: Equatable {
    let zero: T0, one: T1
}

