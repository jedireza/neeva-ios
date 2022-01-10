// Copyright Neeva. All rights reserved.

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
    @State private var offset = CGFloat.zero

    private var dragToCloseThreshold: CGFloat {
        // Using `cardSize` here helps this scale properly with different card sizes,
        // across portrait and landscape modes.
        cardSize * 0.6
    }

    private var progress: CGFloat {
        abs(offset) / (dragToCloseThreshold * 1.5)
    }
    private var angle: Angle {
        .radians(Double(progress * (.pi / 10)).withSign(offset.sign) * layoutDirection.xSign)
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(1 - (progress / 5))
            .rotation3DEffect(angle, axis: (x: 0.0, y: 1.0, z: 0.0))
            .translate(x: offset)
            .opacity(Double(1 - progress))
            .highPriorityGesture(
                DragGesture()
                    .onChanged { value in
                        // Workaround for SwiftUI gestures and UIScrollView not playing well
                        // together. See issue #1378 for details. Only apply an offset if the
                        // translation is mostly in the horizontal direction to avoid translating
                        // the card when the UIScrollView is scrolling.
                        if offset != 0
                            || abs(value.translation.width) > abs(value.translation.height)
                        {
                            offset = value.translation.width
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
                    .onEnded { value in
                        let finalOffset = value.translation.width
                        withAnimation(.interactiveSpring()) {
                            if abs(finalOffset) > dragToCloseThreshold {
                                offset = finalOffset
                                action()

                                // work around reopening tabs causing the state to not be reset
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + .milliseconds(500)
                                ) {
                                    offset = 0
                                }
                            } else {
                                offset = 0
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

    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabGroupCardModel: TabGroupCardModel
    @State private var isPressed = false

    var body: some View {
        GeometryReader { geom in
            VStack(alignment: .center, spacing: 0) {
                Button(action: {
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
                .buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
                .cornerRadius(animate && gridModel.isHidden ? 0 : CardUX.CornerRadius)
                .modifier(
                    BorderTreatment(
                        isSelected: showsSelection && details.isSelected,
                        thumbnailDrawsHeader: details.thumbnailDrawsHeader,
                        isIncognito: gridModel.isIncognito)
                )
                if !details.thumbnailDrawsHeader {
                    HStack(spacing: 0) {
                        if isChildTab(details: details)
                            && (gridModel.animationThumbnailState == .visibleForTrayShow)
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
                            gridModel.animationThumbnailState == .visibleForTrayShow
                                ? titleInMainGrid : details.title
                        ).withFont(.labelMedium)
                            .frame(alignment: .center)
                            .padding(.trailing, 5).padding(.vertical, 4).lineLimit(1)
                    }
                    .frame(width: max(0, geom.size.width), height: CardUX.ButtonSize)
                    .background(Color.clear).opacity(animate && gridModel.isHidden ? 0 : 1)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(details.accessibilityLabel)
        .modifier(ActionsModifier(close: details.closeButtonImage == nil ? nil : details.onClose))
        .accessibilityAddTraits(.isButton)
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
                            .accessibilityLabel("Close \(details.title)")
                            .opacity(animate && gridModel.isHidden ? 0 : 1)
                    },
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
