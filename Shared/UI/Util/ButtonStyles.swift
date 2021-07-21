// Copyright Neeva. All rights reserved.

import SwiftUI

/// A button style that sets its background color to gray when highlighted, matching a table view cell
public struct TableCellButtonStyle: ButtonStyle {
    let padding: EdgeInsets

    public init(padding: EdgeInsets) {
        self.padding = padding
    }
    public init(padding: CGFloat) {
        self.padding = EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
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
                Color(UIColor(light: UIColor(rgb: 0xd1d1d6), dark: UIColor(rgb: 0x3b3b3d)))
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

public struct BigBlueButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 40)
            .frame(height: 48)
            .background(
                Capsule()
                    .fill(Color.ui.adaptive.blue)
                    .opacity(configuration.isPressed ? 0.5 : 1)
            )
    }
}
