// Copyright Neeva. All rights reserved.

import SwiftUI

struct CardTransitionAnimator: View {
    let selectedCardDetails: TabCardDetails
    let cardSize: CGFloat
    let offset: CGPoint
    let containerSize: CGSize

    @EnvironmentObject private var gridModel: GridModel

    var body: some View {
        Card(details: selectedCardDetails, showsSelection: !gridModel.isHidden)
            .runAfter(toggling: gridModel.isHidden, fromTrueToFalse: {
                gridModel.animationThumbnailState = .hidden
            }, fromFalseToTrue: {
                gridModel.hideWithNoAnimation()
            })
            .frame(
                width: gridModel.isHidden ? containerSize.width : cardSize,
                height: gridModel.isHidden ? containerSize.height + CardUX.HeaderSize : CardUX.CardHeight
            )
            .clipped(padding: 2)
            .offset(
                x: gridModel.isHidden ? 0 : offset.x,
                y: gridModel.isHidden ? -CardUX.HeaderSize : offset.y
            )
            .animation(.interpolatingSpring(stiffness: 425, damping: 30))
            .onAppear {
                if !gridModel.isHidden
                    && gridModel.animationThumbnailState == .visibleForTrayHidden {
                        gridModel.isHidden.toggle()
                }
            }
            .allowsHitTesting(false)
    }
}

//struct CardTransitionAnimator_Previews: PreviewProvider {
//    static var previews: some View {
//        CardTransitionAnimator()
//    }
//}
