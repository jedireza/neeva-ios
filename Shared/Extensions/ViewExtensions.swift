// Copyright © Neeva. All rights reserved.
import SwiftUI

// Enable cornerRadius to apply only to specific corners.
// From https://stackoverflow.com/questions/56760335/round-specific-corners-swiftui
private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension UIRectCorner {
    public static let top: UIRectCorner = [.topLeft, .topRight]
    public static let bottom: UIRectCorner = [.bottomLeft, .bottomRight]
    public static let left: UIRectCorner = [.topLeft, .bottomLeft]
    public static let right: UIRectCorner = [.topRight, .bottomRight]
}

extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    public func applyToggleStyle() -> some View {
        toggleStyle(SwitchToggleStyle(tint: Color.ui.adaptive.blue))
    }

    public func tapTargetFrame(alignment: Alignment = .center) -> some View {
        frame(width: 44, height: 44, alignment: alignment)
    }
}

// From https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder public func `if`<Content: View>(
        _ condition: @autoclosure () -> Bool, transform: (Self) -> Content
    ) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
