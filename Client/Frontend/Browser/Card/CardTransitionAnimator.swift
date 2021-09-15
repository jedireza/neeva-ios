// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

/// Custom animator that transitions between the tab switcher and a tab
struct CardTransitionAnimator: View {
    let selectedCardDetails: TabCardDetails
    let cardSize: CGFloat
    /// The location of the card in the tab switcher, relative to the container of the scroll view
    let offset: CGPoint
    /// The size of the area where tab content is displayed when outside the tab switcher
    let containerSize: CGSize
    let safeAreaInsets: EdgeInsets
    /// Whether the toolbar is displayed at the top of the tab switcher
    let topToolbar: Bool

    @EnvironmentObject private var gridModel: GridModel

    private var transitionBottomPadding: CGFloat {
        return topToolbar ? 0 : UIConstants.ToolbarHeight + safeAreaInsets.bottom
    }

    private var transitionTopPadding: CGFloat {
        gridModel.pickerHeight + safeAreaInsets.top
    }

    var body: some View {
        let maxWidth = containerSize.width + safeAreaInsets.leading + safeAreaInsets.trailing
        let maxHeight =
            containerSize.height + safeAreaInsets.bottom - transitionBottomPadding
            - transitionTopPadding + safeAreaInsets.top + CardUX.HeaderSize
        Card(details: selectedCardDetails, showsSelection: !gridModel.isHidden)
            .runAfter(
                toggling: gridModel.isHidden,
                fromTrueToFalse: {
                    gridModel.animationThumbnailState = .hidden
                },
                fromFalseToTrue: {
                    gridModel.hideWithNoAnimation()
                }
            )
            .frame(
                width: gridModel.isHidden ? maxWidth : cardSize,
                height: gridModel.isHidden
                    ? maxHeight : cardSize * CardUX.DefaultTabCardRatio + CardUX.HeaderSize
            )
            .offset(
                x: gridModel.isHidden ? 0 : offset.x + safeAreaInsets.leading,
                y: gridModel.isHidden ? -CardUX.HeaderSize : offset.y + gridModel.scrollOffset
            )
            .animation(.interpolatingSpring(stiffness: 425, damping: 30))
            .onAppear {
                if !gridModel.isHidden
                    && gridModel.animationThumbnailState == .visibleForTrayHidden
                {
                    gridModel.isHidden.toggle()
                }
            }
            .frame(width: maxWidth, height: maxHeight, alignment: .topLeading)
            .allowsHitTesting(false)
            .clipped()
            .padding(.top, transitionTopPadding)
            .padding(.bottom, transitionBottomPadding)
            .ignoresSafeArea()
    }
}

//struct CardTransitionAnimator_Previews: PreviewProvider {
//    static var previews: some View {
//        CardTransitionAnimator()
//    }
//}
