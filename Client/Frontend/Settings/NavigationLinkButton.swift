// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct NavigationLinkButton<Label: View>: View {
    let label: () -> Label
    let action: () -> Void
    let style: Style

    enum Style {
        case link
        case modal
        case loading

        @ViewBuilder fileprivate var symbol: some View {
            switch self {
            case .link:
                Symbol(decorative: .arrowTopRightOnSquare, weight: .medium)
            case .modal:
                Image(systemSymbol: .chevronForward)
                    .font(.footnote.weight(.semibold))
            case .loading:
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            }
        }
    }

    init(
        action: @escaping () -> Void, style: Style = .link,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self.action = action
        self.style = style
    }

    var body: some View {
        let button = Button(action: action) {
            HStack {
                label().foregroundColor(.label)
                Spacer(minLength: 0)
                style.symbol
                    .foregroundColor(.tertiaryLabel)
            }
        }
        if style == .link {
            button.accessibilityAddTraits(.isLink)
        } else {
            button
        }
    }
}

extension NavigationLinkButton where Label == Text {
    init(_ title: String, style: Style = .link, action: @escaping () -> Void) {
        self.label = { Text(title) }
        self.action = action
        self.style = style
    }
}

struct SheetNavigationLink<Label: View, Sheet: View>: View {
    let label: () -> Label
    let sheet: () -> Sheet

    @State var sheetVisible = false

    init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder sheet: @escaping () -> Sheet) {
        self.label = label
        self.sheet = sheet
    }

    var body: some View {
        NavigationLinkButton(
            action: { sheetVisible = true },
            style: .modal,
            label: label
        ).sheet(isPresented: $sheetVisible, content: sheet)
    }
}

extension SheetNavigationLink where Label == Text {
    init(_ title: String, @ViewBuilder sheet: @escaping () -> Sheet) {
        self.label = { Text(title) }
        self.sheet = sheet
    }
}

struct NavigationLinkButton_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NavigationLinkButton("Hello") {}
            NavigationLinkButton("Hello", style: .modal) {}
            NavigationLinkButton(action: {}) {
                Label("Hello", systemSymbol: .starFill)
            }
            NavigationLinkButton(action: {}, style: .modal) {
                Label("Hello", systemSymbol: .starFill)
            }
        }
    }
}
