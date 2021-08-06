// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

struct TabToolbarButton<Content: View>: View {
    let label: Content
    let action: () -> Void

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

        let onBack: () -> Void
        let onForward: () -> Void
        let onOverflow: () -> Void
        let onLongPress: () -> Void

        var body: some View {
            Group {
                TabToolbarButton(
                    label: Symbol(
                        .arrowBackward, size: 20, label: .TabToolbarBackAccessibilityLabel),
                    action: onBack
                )
                .disabled(!model.canGoBack)
                .simultaneousGesture(LongPressGesture().onEnded { _ in onLongPress() })
                if FeatureFlag[.overflowMenu] {
                    TabToolbarButton(
                        label: Symbol(
                            .ellipsisCircle, size: 20, label: .TabToolbarMoreAccessibilityLabel),
                        action: onOverflow
                    )
                } else {
                    TabToolbarButton(
                        label: Symbol(
                            .arrowForward, size: 20, label: .TabToolbarForwardAccessibilityLabel),
                        action: onForward
                    )
                    .disabled(!model.canGoForward)
                    .simultaneousGesture(LongPressGesture().onEnded { _ in onLongPress() })
                }
            }
        }
    }

    struct NeevaMenu: View {
        let action: () -> Void

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
        let action: () -> Void

        @Environment(\.isIncognito) private var isIncognito
        @EnvironmentObject var model: TabToolbarModel

        var body: some View {
            TabToolbarButton(
                label: Symbol(.bookmark, size: 20, weight: .medium, label: "Add To Space"),
                action: action
            )
            .disabled(isIncognito || !model.isPage)
        }
    }

    struct ShowTabs: View {
        let action: () -> Void
        let buildMenu: () -> UIMenu?

        var body: some View {
            // TODO: when dropping support for iOS 14, change this to a Menu view with a primaryAction
            UIKitButton(action: action) {
                $0.setImage(Symbol.uiImage(.squareOnSquare, size: 20), for: .normal)
                $0.setDynamicMenu(buildMenu)
                $0.accessibilityLabel = "Show Tabs"
            }
        }
    }
}
