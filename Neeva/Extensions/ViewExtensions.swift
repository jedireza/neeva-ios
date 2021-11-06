// Copyright Neeva. All rights reserved.

import SwiftUI

/// Wraps a border around the content to which it is applied, resulting in
/// the content being `2 * lineWidth` larger in width and height.
struct RoundedOuterBorder: ViewModifier {
    let cornerRadius: CGFloat
    let color: Color
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .cornerRadius(cornerRadius)
            .padding(lineWidth)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius + lineWidth)
                    .strokeBorder(color, lineWidth: lineWidth)
            )
    }
}

extension View {
    public func roundedOuterBorder(cornerRadius: CGFloat, color: Color, lineWidth: CGFloat = 1)
        -> some View
    {
        self.modifier(
            RoundedOuterBorder(cornerRadius: cornerRadius, color: color, lineWidth: lineWidth))
    }
}

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
                    .onAppear {
                        withAnimation(
                            self.animation,
                            {
                                self.isAtMaxScale.toggle()
                            })
                    }
            )
    }
}

extension View {
    public func throbbingHighlightBorderStyle(highlight: Color, staticColorMode: Bool? = false)
        -> some View
    {
        self.modifier(
            ThrobbingHighlightBorder(highlight: highlight, staticColorMode: staticColorMode!))
    }
}

extension View {
    /// Inspired by React’s `useEffect` hook, this modifier calls `perform(deps)` both `onAppear` and whenever `deps` changes.
    func useEffect<T: Equatable>(deps: T, perform updater: @escaping (T) -> Void) -> some View {
        self.onChange(of: deps, perform: updater)
            .onAppear { updater(deps) }
    }
    /// Inspired by React’s `useEffect` hook, this modifier calls `perform(deps)` both `onAppear` and whenever `deps` changes.
    func useEffect<T0: Equatable, T1: Equatable>(
        deps zero: T0, _ one: T1, perform updater: @escaping (T0, T1) -> Void
    ) -> some View {
        self.onChange(of: Pair(zero: zero, one: one)) { updater($0.zero, $0.one) }
            .onAppear { updater(zero, one) }
    }

    func useEffect<T0: Equatable, T1: Equatable, T2: Equatable>(
        deps zero: T0, _ one: T1, _ two: T2, perform updater: @escaping (T0, T1, T2) -> Void
    ) -> some View {
        self.onChange(of: Tuple(zero: zero, one: one, two: two)) {
            updater($0.zero, $0.one, $0.two)
        }
        .onAppear { updater(zero, one, two) }
    }
}

private struct Pair<T0: Equatable, T1: Equatable>: Equatable {
    let zero: T0, one: T1
}

private struct Tuple<T0: Equatable, T1: Equatable, T2: Equatable>: Equatable {
    let zero: T0, one: T1, two: T2
}
