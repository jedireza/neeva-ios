// Copyright Neeva. All rights reserved.

import SwiftUI

struct CardTransitionAnimator: View {
    let selectedCardDetails: TabCardDetails
    let cardSize: CGFloat
    let offset: CGPoint
    let containerSize: CGSize
    let safeAreaInsets: EdgeInsets
    let topToolbar: Bool

    @EnvironmentObject private var gridModel: GridModel

    private var transitionBottomPadding: CGFloat {
        topToolbar ? 0 : UIConstants.ToolbarHeight + safeAreaInsets.bottom
    }

    private var transitionTopPadding: CGFloat {
        topToolbar ? UIConstants.TopToolbarHeightWithToolbarButtonsShowing + safeAreaInsets.top : 0
    }

    var body: some View {
        let maxWidth = containerSize.width + safeAreaInsets.leading + safeAreaInsets.trailing
        let maxHeight =
            containerSize.height + safeAreaInsets.bottom - transitionBottomPadding
            - transitionTopPadding
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
                height: gridModel.isHidden ? maxHeight + CardUX.HeaderSize : CardUX.CardHeight
            )
            .offset(
                x: gridModel.isHidden ? 0 : offset.x + safeAreaInsets.leading,
                y: gridModel.isHidden ? -CardUX.HeaderSize : offset.y + safeAreaInsets.top
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
