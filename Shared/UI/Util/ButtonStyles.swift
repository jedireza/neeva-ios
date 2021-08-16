// Copyright Neeva. All rights reserved.

import SwiftUI

/// A button style that sets its background color to gray when highlighted, matching a table view cell
public struct TableCellButtonStyle: ButtonStyle {
    let padding: EdgeInsets

    public init(padding: EdgeInsets) {
        self.padding = padding
    }
    public init(padding: CGFloat) {
        self.padding = EdgeInsets(
            top: padding, leading: padding, bottom: padding, trailing: padding)
    }
    public init() {
        self.padding = EdgeInsets()
    }
    public init(padding edges: Edge.Set, _ padding: CGFloat) {
        self.padding = EdgeInsets(edges: edges, amount: padding)
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .background(
                Color.selectedCell
                    .opacity(configuration.isPressed ? 1 : 0)
                    .padding(padding)
            )
    }
}

/// A button style that prevents the button’s label from dimming when the user presses down on it
public struct HighlightlessButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public struct NeevaButtonStyle: ButtonStyle {
    public enum VisualSpec {
        case primary
        case secondary
    }

    let visualSpec: VisualSpec
    @Environment(\.isEnabled) private var isEnabled

    public init(_ visual: VisualSpec) {
        self.visualSpec = visual
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(visualSpec == VisualSpec.primary ? .white : .label)
            .padding(.vertical, 8)
            .frame(height: 48)
            .background(
                Capsule()
                    .fill(
                        visualSpec == VisualSpec.primary
                            ? (configuration.isPressed
                                ? Color.brand.variant.blue : Color.ui.adaptive.blue)
                            : (configuration.isPressed
                                ? Color.systemFill : Color.quaternarySystemFill)
                    )
                    .opacity(isEnabled ? 1 : 0.5)
            )
    }
}
