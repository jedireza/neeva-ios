// Copyright Neeva. All rights reserved.

import SwiftUI

struct CardTransitionModifier<Details: CardDetails>: ViewModifier {
    let details: Details
    let containerGeometry: GeometryProxy
    var extraBottomPadding: CGFloat = 0

    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel

    let animation = Animation.interpolatingSpring(stiffness: 425, damping: 30)

    func body(content: Content) -> some View {
        content
            .zIndex(details.isSelected ? 1 : 0)
            .opacity(details.isSelected && gridModel.animationThumbnailState != .hidden ? 0 : 1)
            .animation(nil)
            .overlay(overlay)
    }

    var overlay: some View {
        GeometryReader { geom in
            if details.isSelected && gridModel.animationThumbnailState != .hidden {
                let rect = calculateCardRect(geom: geom)
                overlayCard
                    .offset(x: rect.minX, y: rect.minY)
                    .frame(width: rect.width, height: rect.height)
                    .animation(animation)
                    .transition(.identity)
                    .useEffect(deps: gridModel.animationThumbnailState) { _ in
                        /// This needs to run after `CardGrid` has called `gridModel.scrollToSelectedTab()`,
                        /// which is also triggered by observing `gridModel.animationThumbnailState`. A trip
                        /// through `DispatchQueue.main` does the trick.
                        DispatchQueue.main.async {
                            if gridModel.animationThumbnailState != .hidden {
                                withAnimation(animation) {
                                    gridModel.isHidden =
                                        (gridModel.animationThumbnailState == .visibleForTrayHidden)
                                }
                            }
                        }
                    }
            }
        }
        .ignoresSafeArea(edges: [.bottom])
    }

    @ViewBuilder var overlayCard: some View {
        if let tabGroupDetails = details as? TabGroupCardDetails {
            let selectedTabDetails = (tabGroupDetails.allDetails.first { $0.isSelected })!
            Card(details: selectedTabDetails, showsSelection: !gridModel.isHidden, animate: true)
        } else {
            Card(details: details, showsSelection: !gridModel.isHidden, animate: true)
        }
    }

    func calculateCardRect(geom: GeometryProxy) -> CGRect {
        if !gridModel.isHidden {
            return geom.frame(in: .local)
        }

        let cardFrame = geom.frame(in: .global)
        let containerFrame = containerGeometry.frame(in: .global)

        let x = containerFrame.minX - cardFrame.minX
        let y = containerFrame.minY - cardFrame.minY
        let width = containerFrame.size.width
        let height = containerFrame.size.height - extraBottomPadding + CardUX.HeaderSize

        return CGRect(x: x, y: y, width: width, height: height)
    }
}
