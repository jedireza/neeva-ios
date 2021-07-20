// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI
import UniformTypeIdentifiers

fileprivate struct CardAdjustments<Details: CardDetails>: ViewModifier {
    let details: Details
    let isDragging: Bool

    @EnvironmentObject private var gridModel: GridModel
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .opacity((details.isSelected && gridModel.animationThumbnailState != .hidden) || isDragging ? 0 : 1)
            .animation(nil)
            .overlay(
                Color.tertiarySystemFill
                    .cornerRadius(CardUX.CornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: CardUX.CornerRadius)
                            .inset(by: -3)
                            .stroke(Color.black.opacity(colorScheme == .dark ? 0.7 : 0.1), lineWidth: 3)
                            .offset(x: 3, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: CardUX.CornerRadius)
                                    .inset(by: -3)
                                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.3), lineWidth: 3)
                                    .offset(x: -3, y: -3)
                            )
                            .blur(radius: 3)
                            .clipShape(RoundedRectangle(cornerRadius: CardUX.CornerRadius))
                    )
                    .opacity(isDragging ? 1 : 0)
            )
    }
}

struct SpaceCardsView: View {
    @EnvironmentObject var spacesModel: SpaceCardModel
    var body: some View {
        ForEach(spacesModel.allDetails, id: \.id) { details in
            FittedCard(details: details)
                .modifier(CardAdjustments(details: details, isDragging: false))
                .id(details.id)
        }
    }
}

fileprivate class DraggableTab: NSObject, NSItemProviderWriting {
    static let uti = UTType("com.neeva.tab")!
    static var writableTypeIdentifiersForItemProvider: [String] { [uti.identifier] }

    let id: String
    init(id: String) {
        self.id = id
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        if typeIdentifier == Self.uti.identifier {
            completionHandler(id.data(using: .utf8), nil)
        } else {
            completionHandler(nil, nil)
        }
        return nil
    }

}

struct TabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel

    @State private var dragging: TabCardDetails?
    @Environment(\.cardSize) private var cardSize

    // drag and drop based on https://stackoverflow.com/a/63438481/5244995
    @ViewBuilder
    var body: some View {
        if FeatureFlag[.groupsInSwitcher] {
            ForEach(tabGroupModel.allDetails, id: \.id) { details in
                FittedCard(details: details)
                    .modifier(CardAdjustments(details: details, isDragging: false))
            }
            ForEach(tabModel.allDetailsWithExclusionList, id: \.id) { details in
                FittedCard(details: details)
                    .modifier(CardAdjustments(details: details, isDragging: false))
            }
        } else {
            ForEach(tabModel.allDetails, id: \.id) { details in
                FittedCard(details: details)
                    .onDrag {
                        dragging = details
                        return NSItemProvider(object: DraggableTab(id: details.id))
                    }
                    .modifier(CardAdjustments(details: details, isDragging: dragging?.id == details.id))
                    .onDrop(of: [DraggableTab.uti, .url, .text], delegate: DropDelegate(item: details, items: $tabModel.allDetails, dragging: $dragging))
            }.animation(.interactiveSpring().delay(0.1), value: tabModel.allDetails.map(\.id))
        }
    }

    private struct DropDelegate: SwiftUI.DropDelegate {
        let item: TabCardDetails
        @Binding var items: [TabCardDetails]
        @Binding var dragging: TabCardDetails?

        func validateDrop(info: DropInfo) -> Bool {
            info.hasItemsConforming(to: [DraggableTab.uti]) || item.validateDrop(info: info)
        }

        func dropEntered(info: DropInfo) {
            print("entered \(item.manager.get(for: item.id)!.displayTitle)")
            if let dragging = dragging,
               item.id != dragging.id {
                let from = items.firstIndex { $0.id == dragging.id }
                let to = items.firstIndex { $0.id == item.id }
                if let from = from, let to = to,
                   items[to].id != dragging.id {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) {
                        items.move(fromOffsets: IndexSet(integer: from),
                            toOffset: to > from ? to + 1 : to)
                    }
                }
            }
        }

        func dropUpdated(info: DropInfo) -> DropProposal? {
//            print(info.location)
            return DropProposal(operation: .move)
        }

        func performDrop(info: DropInfo) -> Bool {
            if item.validateDrop(info: info) {
                return item.performDrop(info: info)
            } else {
                dragging = nil
                return true
            }
        }
    }
}
