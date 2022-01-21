// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum CardUX {
    static let DefaultCardSize: CGFloat = 160
    static let ShadowRadius: CGFloat = 2
    static let CornerRadius: CGFloat = 16
    static let CompactCornerRadius: CGFloat = 8
    static let FaviconCornerRadius: CGFloat = 4
    static let ButtonSize: CGFloat = 28
    static let FaviconSize: CGFloat = 18
    static let CloseButtonSize: CGFloat = 24
    static let HeaderSize: CGFloat = ButtonSize + 1
    static let CardHeight: CGFloat = 174
    static let DefaultTabCardRatio: CGFloat = 200 / 164
}

struct BorderTreatment: ViewModifier {
    let isSelected: Bool
    let thumbnailDrawsHeader: Bool
    let isIncognito: Bool
    var cornerRadius: CGFloat = CardUX.CornerRadius

    func body(content: Content) -> some View {
        content
            .shadow(radius: thumbnailDrawsHeader ? 0 : CardUX.ShadowRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected
                            ? (isIncognito ? Color.label : Color.ui.adaptive.blue) : Color.clear,
                        lineWidth: 3)
            )
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct DragToCloseInteraction: ViewModifier {
    let action: () -> Void
    @State private var hasExceededThreshold = false

    @Environment(\.cardSize) private var cardSize
    @Environment(\.layoutDirection) private var layoutDirection

    @EnvironmentObject private var browserModel: BrowserModel

    @GestureState private var offset = CGFloat.zero
    @State private var animatedOffset = CGFloat.zero

    private var dragToCloseThreshold: CGFloat {
        // Using `cardSize` here helps this scale properly with different card sizes,
        // across portrait and landscape modes.
        cardSize * 0.6
    }

    private var progress: CGFloat {
        (abs(offset) + abs(animatedOffset)) / (dragToCloseThreshold * 1.5)
    }
    private var angle: Angle {
        .radians(
            Double(progress * (.pi / 10)).withSign((offset + animatedOffset).sign)
                * layoutDirection.xSign)
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(1 - (progress / 5))
            .rotation3DEffect(angle, axis: (x: 0.0, y: 1.0, z: 0.0))
            .translate(x: offset + animatedOffset)
            .opacity(Double(1 - progress))
            .highPriorityGesture(
                DragGesture()
                    .updating($offset) { value, offset, _ in
                        // Workaround for SwiftUI gestures and UIScrollView not playing well
                        // together. See issue #1378 for details. Only apply an offset if the
                        // translation is mostly in the horizontal direction to avoid translating
                        // the card when the UIScrollView is scrolling.
                        if offset != 0
                            || abs(value.translation.width) > abs(value.translation.height)
                        {
                            offset = value.translation.width
                            DispatchQueue.main.async { [offset] in
                                if abs(offset) > dragToCloseThreshold {
                                    if !hasExceededThreshold {
                                        hasExceededThreshold = true
                                        Haptics.swipeGesture()
                                    }
                                } else {
                                    hasExceededThreshold = false
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        let finalOffset = value.translation.width
                        animatedOffset = finalOffset
                        withAnimation(.interactiveSpring(dampingFraction: 0.65)) {
                            if abs(finalOffset) > dragToCloseThreshold {
                                animatedOffset = dragToCloseThreshold * 2
                                action()

                                // work around reopening tabs causing the state to not be reset
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    animatedOffset = 0
                                }
                            } else {
                                animatedOffset = 0
                            }
                        }
                    }
            )
    }
}

extension EnvironmentValues {
    private struct CardSizeKey: EnvironmentKey {
        static var defaultValue: CGFloat = CardUX.DefaultCardSize
    }

    public var cardSize: CGFloat {
        get { self[CardSizeKey.self] }
        set { self[CardSizeKey.self] = newValue }
    }

    private struct AspectRatioKey: EnvironmentKey {
        static var defaultValue: CGFloat = 1
    }

    public var aspectRatio: CGFloat {
        get { self[AspectRatioKey.self] }
        set { self[AspectRatioKey.self] = newValue }
    }

    private struct SelectionCompletionKey: EnvironmentKey {
        static var defaultValue: () -> Void = {}
    }
    public var selectionCompletion: () -> Void {
        get { self[SelectionCompletionKey.self] }
        set { self[SelectionCompletionKey.self] = newValue }
    }
}

/// A card that constrains itself to the default height and provided width.
struct FittedCard<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    var dragToClose: Bool = true

    @Environment(\.cardSize) private var cardSize
    @Environment(\.aspectRatio) private var aspectRatio

    var body: some View {
        Card(details: details, dragToClose: dragToClose)
            .frame(width: cardSize, height: cardSize * aspectRatio + CardUX.HeaderSize)
    }
}

/// A flexible card that takes up as much space as it is allotted.
struct Card<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    var dragToClose = true
    /// Whether — if this card is selected — the blue border should be drawn
    var showsSelection = true
    var animate = false

    var tabCardDetail: TabCardDetails? {
        details as? TabCardDetails
    }

    var tabGroupCardDetail: TabGroupCardDetails? {
        details as? TabGroupCardDetails
    }

    var titleInMainGrid: String {
        if let rootUUID = tabCardDetail?.manager.get(for: details.id)?.rootUUID,
            Defaults[.tabGroupNames][rootUUID] != nil
        {
            return Defaults[.tabGroupNames][rootUUID]!
        } else {
            return details.title
        }
    }

    var iconInMainGrid: String {
        details.id == tabGroupCardModel.manager.get(for: details.id)?.children.first?.parentSpaceID
            ? "bookmark.fill" : "square.grid.2x2.fill"
    }

    func isChildTab(details: Details) -> Bool {
        if let currentTab = tabCardDetail?.manager.get(for: details.id) {
            return tabGroupCardModel.manager.childTabs.contains(currentTab)
        } else {
            return false
        }
    }

    @Environment(\.selectionCompletion) private var selectionCompletion
    @Environment(\.isIncognito) private var isIncognito
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var tabGroupCardModel: TabGroupCardModel
    @State private var isPressed = false

    var body: some View {
        GeometryReader { geom in
            VStack(alignment: .center, spacing: 0) {
                Button(action: {
                    if let tabGroupCardDetail = tabGroupCardDetail {
                        tabGroupCardModel.detailedTabGroup = tabGroupCardDetail
                    }

                    details.onSelect()
                    selectionCompletion()
                }) {
                    details.thumbnail
                        .frame(
                            width: max(0, geom.size.width),
                            height: max(
                                0,
                                geom.size.height
                                    - (details.thumbnailDrawsHeader ? 0 : CardUX.HeaderSize)),
                            alignment: .top
                        )
                        .clipped()
                }
                .buttonStyle(.reportsPresses(to: $isPressed))
                .cornerRadius(animate && !browserModel.showGrid ? 0 : CardUX.CornerRadius)
                .modifier(
                    BorderTreatment(
                        isSelected: showsSelection && details.isSelected,
                        thumbnailDrawsHeader: details.thumbnailDrawsHeader,
                        isIncognito: isIncognito)
                )
                if !details.thumbnailDrawsHeader {
                    HStack(spacing: 0) {
                        if !FeatureFlag[.tabGroupsNewDesign] && isChildTab(details: details)
                            && (browserModel.cardTransition == .visibleForTrayShow)
                        {
                            Image(systemName: iconInMainGrid)
                                .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                                .cornerRadius(CardUX.FaviconCornerRadius)
                                .padding(5)

                        } else {
                            details.favicon
                                .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                                .cornerRadius(CardUX.FaviconCornerRadius)
                                .padding(5)
                        }
                        Text(
                            !FeatureFlag[.tabGroupsNewDesign]
                                && browserModel.cardTransition == .visibleForTrayShow
                                ? titleInMainGrid : details.title
                        ).withFont(.labelMedium)
                            .frame(alignment: .center)
                            .padding(.trailing, 5).padding(.vertical, 4).lineLimit(1)
                    }
                    .frame(width: max(0, geom.size.width), height: CardUX.ButtonSize)
                    .background(Color.clear)
                    .opacity(animate && !browserModel.showGrid ? 0 : 1)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(details.accessibilityLabel)
        .modifier(ActionsModifier(close: details.closeButtonImage == nil ? nil : details.onClose))
        .accessibilityAddTraits(.isButton)
        .accesibilityFocus(
            shouldFocus: details.isSelected, trigger: browserModel.cardTransition == .hidden
        )
        .onDrop(of: ["public.url", "public.text"], delegate: details)
        .if(let: details.closeButtonImage) { buttonImage, view in
            view
                .overlay(
                    Button(action: details.onClose) {
                        Image(uiImage: buttonImage).resizable().renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(.secondaryLabel)
                            .padding(6)
                            .frame(width: CardUX.CloseButtonSize, height: CardUX.CloseButtonSize)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(Circle())
                            .padding(6)
                            .opacity(animate && !browserModel.showGrid ? 0 : 1)
                    }
                    .accessibilityHidden(true),  // use the Close action instead
                    alignment: .topTrailing
                )
                .if(dragToClose) { view in
                    view.modifier(DragToCloseInteraction(action: details.onClose))
                }
        }
        .scaleEffect(isPressed ? 0.95 : 1)
    }

    private struct ActionsModifier: ViewModifier {
        let close: (() -> Void)?

        func body(content: Content) -> some View {
            if let close = close {
                content.accessibilityAction(named: "Close", close)
            } else {
                content
            }
        }
    }
}
