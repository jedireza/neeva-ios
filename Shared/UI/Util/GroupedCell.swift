// Copyright Neeva. All rights reserved.

import SwiftUI

public enum GroupedCellUX {
    public static let minCellHeight: CGFloat = 52
    public static let padding: CGFloat = 16
    public static let spacing: CGFloat = 12
    public static let cornerRadius: CGFloat = 12
}

// not using a `HorizontalAlignment` because it has ability to do custom alignments which we don’t want
public enum GroupedCellAlignment {
    case leading
    case center
    case trailing
}

/// A container for `GroupedCell`s. It applies the proper padding, spacing and background color around the cells.
public struct GroupedStack<Content: View>: View {
    let content: () -> Content
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .accentColor(.ui.adaptive.blue)
        .padding(GroupedCellUX.padding)
    }
}

/// A grouped cell. Use this to display content other than a button.
///
/// `GroupedCell` automatically applies a minimum height, horizontal padding, background, and rounded corners.
/// Pass a `GroupedCellAlignment` to change your content’s horizontal position.
public struct GroupedCell<Content: View>: View {
    let alignment: GroupedCellAlignment
    let content: () -> Content
    let roundedCorners: UIRectCorner

    public init(
        alignment: GroupedCellAlignment = .center, @ViewBuilder content: @escaping () -> Content,
        roundedCorners: UIRectCorner = .allCorners
    ) {
        self.alignment = alignment
        self.content = content
        self.roundedCorners = roundedCorners
    }

    public var body: some View {
        GroupedCell<ContentContainer>.Decoration(
            content: {
                ContentContainer(alignment: alignment, content: content)
            }, roundedCorners: roundedCorners)
    }
}

/// A grouped cell containing a button.
///
/// The button automatically gets `TableCellButtonStyle` applied,
/// and adds all of the same styling that `GroupedCell` adds.
public struct GroupedCellButton<Label: View>: View {
    let alignment: GroupedCellAlignment
    let action: () -> Void
    let longPressAction: (() -> Void)?
    let label: () -> Label

    public init(
        alignment: GroupedCellAlignment = .center, action: @escaping () -> Void,
        longPressAction: (() -> Void)? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.alignment = alignment
        self.action = action
        self.label = label
        self.longPressAction = longPressAction
    }

    public var body: some View {
        GroupedCell.Decoration {
            LongPressButton(action: action, longPressAction: longPressAction) {
                GroupedCell.ContentContainer(alignment: alignment, content: label)
            }
            .buttonStyle(TableCellButtonStyle())
        }
    }
}

extension GroupedCellButton where Label == Text.WithFont {
    public init<S: StringProtocol>(
        _ label: S, style: FontStyle = .bodyLarge, weight: UIFont.Weight? = nil,
        action: @escaping () -> Void, longPressAction: (() -> Void)? = nil
    ) {
        self.label = { Text(label).withFont(style, weight: weight) }
        self.alignment = .center
        self.action = action
        self.longPressAction = longPressAction
    }
}

// MARK: - Internal sizing/layout views
extension GroupedCell {
    /// Adds the standard background and rounded corners to the content.
    public struct Decoration: View {
        let content: () -> Content
        var roundedCorners: UIRectCorner

        public init(
            @ViewBuilder content: @escaping () -> Content,
            roundedCorners: UIRectCorner = .allCorners
        ) {
            self.content = content
            self.roundedCorners = roundedCorners
        }

        public var body: some View {
            content()
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(GroupedCellUX.cornerRadius, corners: roundedCorners)
        }
    }

    /// Applies the min height, padding, and alignment.
    public struct ContentContainer: View {
        let alignment: GroupedCellAlignment
        let content: () -> Content
        public init(alignment: GroupedCellAlignment, @ViewBuilder content: @escaping () -> Content)
        {
            self.alignment = alignment
            self.content = content
        }

        public var body: some View {
            HStack(spacing: 0) {
                if alignment == .leading {
                    Color.clear.frame(width: GroupedCellUX.padding)
                } else {
                    Spacer(minLength: GroupedCellUX.padding)
                }
                ZStack {
                    Color.clear.frame(width: 1, height: GroupedCellUX.minCellHeight)
                    content()
                }
                if alignment == .trailing {
                    Color.clear.frame(width: GroupedCellUX.padding)
                } else {
                    Spacer(minLength: GroupedCellUX.padding)
                }
            }
        }
    }
}

struct OverlayGroupButton_Previews: PreviewProvider {
    static var previews: some View {
        GroupedCellButton(action: {}) {
            Text("Test")
        }
    }
}
