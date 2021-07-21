// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

enum GroupedCellUX {
    static let minCellHeight: CGFloat = 52
    static let horizontalPadding: CGFloat = 16
    static let spacing: CGFloat = 12
    static let cornerRadius: CGFloat = 12
}

// not using a `HorizontalAlignment` because it has ability to do custom alignments which we don’t want
enum GroupedCellAlignment {
    case leading
    case center
    case trailing
}

/// A container for `GroupedCell`s. It applies the proper padding, spacing and background color around the cells.
struct GroupedStack<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .accentColor(.ui.adaptive.blue)
        .padding(16)
        .background(Color.groupedBackground.ignoresSafeArea())
    }
}

/// A grouped cell. Use this to display content other than a button.
///
/// `GroupedCell` automatically applies a minimum height, horizontal padding, background, and rounded corners.
/// Pass a `GroupedCellAlignment` to change your content’s horizontal position.
struct GroupedCell<Content: View>: View {
    let alignment: GroupedCellAlignment
    let content: () -> Content

    init(alignment: GroupedCellAlignment = .center, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        GroupedCell<ContentContainer>.Decoration {
            ContentContainer(alignment: alignment, content: content)
        }
    }
}

/// A grouped cell containing a button.
///
/// The button automatically gets `TableCellButtonStyle` applied,
/// and adds all of the same styling that `GroupedCell` adds.
struct GroupedCellButton<Label: View>: View {
    let alignment: GroupedCellAlignment
    let action: () -> ()
    let label: () -> Label

    init(alignment: GroupedCellAlignment = .center, action: @escaping () -> (), @ViewBuilder label: @escaping () -> Label) {
        self.alignment = alignment
        self.action = action
        self.label = label
    }

    var body: some View {
        GroupedCell.Decoration {
            Button(action: action) {
                GroupedCell.ContentContainer(alignment: alignment, content: label)
            }.buttonStyle(TableCellButtonStyle())
        }
    }
}

extension GroupedCellButton where Label == Text.WithFont {
    init<S: StringProtocol>(_ label: S, style: FontStyle = .bodyLarge, weight: UIFont.Weight? = nil, action: @escaping () -> ()) {
        self.label = { Text(label).withFont(style, weight: weight) }
        self.alignment = .center
        self.action = action
    }
}

// MARK: - Internal sizing/layout views
extension GroupedCell {
    /// Adds the standard background and rounded corners to the content.
    struct Decoration: View {
        let content: () -> Content
        var body: some View {
            content()
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(GroupedCellUX.cornerRadius)
        }
    }

    /// Applies the min height, padding, and alignment.
    struct ContentContainer: View {
        let alignment: GroupedCellAlignment
        let content: () -> Content
        var body: some View {
            HStack(spacing: 0) {
                if alignment == .leading {
                    Color.clear.frame(width: GroupedCellUX.horizontalPadding)
                } else {
                    Spacer(minLength: GroupedCellUX.horizontalPadding)
                }
                ZStack {
                    Color.clear.frame(width: 1, height: GroupedCellUX.minCellHeight)
                    content()
                }
                if alignment == .trailing {
                    Color.clear.frame(width: GroupedCellUX.horizontalPadding)
                } else {
                    Spacer(minLength: GroupedCellUX.horizontalPadding)
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
