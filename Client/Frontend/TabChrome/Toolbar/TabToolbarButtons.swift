// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

struct TabToolbarButton<Content: View>: View {
    let label: Content
    let action: () -> Void
    let longPressAction: (() -> Void)?

    @State private var didLongPress = false
    @Environment(\.isEnabled) private var isEnabled

    public init(
        label: Content,
        action: @escaping () -> Void,
        longPressAction: (() -> Void)? = nil
    ) {
        self.label = label
        self.action = action
        self.longPressAction = longPressAction
    }

    var body: some View {
        Button(action: {
            if !didLongPress {
                action()
            }
            didLongPress = false
        }) {
            Spacer(minLength: 0)
            label.tapTargetFrame()
            Spacer(minLength: 0)
        }
        .accentColor(isEnabled ? .label : .quaternaryLabel)
        .simultaneousGesture(
            LongPressGesture().onEnded { _ in
                if let longPressAction = longPressAction {
                    longPressAction()
                    didLongPress = true
                }
            }
        )
    }
}

enum TabToolbarButtons {
    struct BackForward: View {
        let weight: Font.Weight
        let onBack: () -> Void
        let onForward: () -> Void
        let onLongPress: () -> Void

        @ViewBuilder var experimentalButton: some View {
            if !FeatureFlag[.overflowMenu] {
                TabToolbarButton(
                    label: Symbol(
                        .arrowForward, size: 20, weight: weight,
                        label: .TabToolbarForwardAccessibilityLabel),
                    action: onForward,
                    longPressAction: onLongPress
                )
                .disabled(!model.canGoForward)
            }
        }

        @EnvironmentObject private var model: TabChromeModel
        var body: some View {
            Group {
                TabToolbarButton(
                    label: Symbol(
                        .arrowBackward, size: 20, weight: weight,
                        label: .TabToolbarBackAccessibilityLabel),
                    action: onBack,
                    longPressAction: onLongPress
                )
                .disabled(!model.canGoBack)
                experimentalButton
            }
        }
    }

    struct OverflowMenu: View {
        let action: () -> Void
        let onLongPress: () -> Void

        @Environment(\.isIncognito) private var isIncognito

        var body: some View {
            TabToolbarButton(
                label: Symbol(
                    FeatureFlag[.overflowIconOnOverflowMenu]
                        ? .ellipsisCircle
                        : .squareAndArrowUp, size: 20, weight: .regular,
                    label: .TabToolbarMoreAccessibilityLabel),
                action: action,
                longPressAction: onLongPress
            )
        }
    }

    struct NeevaMenu: View {
        let iconWidth: CGFloat
        let action: () -> Void

        @Environment(\.isIncognito) private var isIncognito

        var body: some View {
            TabToolbarButton(
                label: Image("neevaMenuIcon")
                    .renderingMode(isIncognito ? .template : .original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconWidth)
                    .accessibilityLabel("Neeva Menu"),
                action: action
            )
        }
    }

    struct AddToSpace: View {
        let weight: NiconFont
        let action: () -> Void

        @Environment(\.isIncognito) private var isIncognito
        @EnvironmentObject private var model: TabChromeModel

        var body: some View {
            TabToolbarButton(
                label: Symbol(.bookmark, size: 20, weight: weight, label: "Add To Space"),
                action: action
            )
            .disabled(isIncognito || !model.isPage)
        }
    }

    struct ShowTabs: View {
        let weight: UIImage.SymbolWeight
        let action: () -> Void
        let buildMenu: () -> UIMenu?

        var body: some View {
            SecondaryMenuButton(action: action) {
                $0.setImage(Symbol.uiImage(.squareOnSquare, size: 20, weight: weight), for: .normal)
                $0.setDynamicMenu(buildMenu)
                $0.accessibilityLabel = "Show Tabs"
            }
        }
    }
}
