// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import SFSafeSymbols

struct TabToolbarButton<Content: View>: View {
    let label: Content
    let action: () -> ()

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Spacer()
            label
                .frame(width: 44, height: 44)
            Spacer()
        }.accentColor(isEnabled ? .label : .quaternaryLabel)
    }
}

enum TabToolbarButtons {
    struct BackForward: View {
        @ObservedObject var model: TabToolbarModel

        let onBack: () -> ()
        let onForward: () -> ()
        let onLongPress: () -> ()

        var body: some View {
            Group {
                TabToolbarButton(label: Symbol(.arrowBackward, size: 20, label: .TabToolbarBackAccessibilityLabel), action: onBack)
                    .disabled(!model.canGoBack)
                TabToolbarButton(label: Symbol(.arrowForward, size: 20, label: .TabToolbarForwardAccessibilityLabel), action: onForward)
                    .disabled(!model.canGoForward)
            }.simultaneousGesture(LongPressGesture().onEnded { _ in onLongPress() })
        }
    }

    struct NeevaMenu: View {
        let action: () -> ()

        @Environment(\.isIncognito) private var isIncognito

        var body: some View {
            TabToolbarButton(
                label: Image("neevaMenuIcon")
                    .renderingMode(isIncognito ? .template : .original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22)
                    .accessibilityLabel("Neeva Menu"),
                action: action
            )
        }
    }

    struct AddToSpace: View {
        let action: () -> ()

        var body: some View {
            TabToolbarButton(label: Symbol(.bookmark, size: 20, weight: .medium, label: "Add To Space"), action: action)
        }
    }

    struct ShowTabs: View {
        let action: () -> ()
        let buildMenu: () -> UIMenu?

        var body: some View {
            UIKitButton(action: action) {
                $0.setImage(Symbol.uiImage(.squareOnSquare, size: 20), for: .normal)
                $0.setDynamicMenu(buildMenu)
            }
        }
    }
}
