// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

/// Custom animator that transitions between the tab switcher and a tab
struct CardTransitionAnimator: View {
    let cardSize: CGFloat
    /// The size of the area where tab content is displayed when outside the tab switcher
    let containerSize: CGSize
    let safeAreaInsets: EdgeInsets
    /// Whether the toolbar is displayed at the top of the tab switcher
    let topToolbar: Bool
    let animation: Animation = .interpolatingSpring(stiffness: 425, damping: 30)

    @EnvironmentObject private var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel

    var isSelectedTabInGroup: Bool {
        let selectedTab = tabModel.manager.selectedTab!
        return tabGroupModel.representativeTabs.contains { $0.rootUUID == selectedTab.rootUUID }
    }

    private var transitionBottomPadding: CGFloat {
        return topToolbar ? 0 : UIConstants.ToolbarHeight + safeAreaInsets.bottom
    }

    private var transitionTopPadding: CGFloat {
        gridModel.pickerHeight + safeAreaInsets.top
    }

    var selectedCardDetails: TabCardDetails? {
        return tabModel.allDetailsWithExclusionList.first(where: \.isSelected)
            ?? tabGroupModel.allDetails
            .compactMap { $0.allDetails.first(where: \.isSelected) }
            .first
    }

    var maxWidth: CGFloat {
        containerSize.width + safeAreaInsets.leading + safeAreaInsets.trailing
    }

    var maxHeight: CGFloat {
        containerSize.height + safeAreaInsets.bottom - transitionBottomPadding
            - transitionTopPadding + safeAreaInsets.top + CardUX.HeaderSize
    }

    var frame: CGRect {
        gridModel.isHidden
            ? CGRect(width: maxWidth, height: maxHeight)
            : ((isSelectedTabInGroup && gridModel.animationThumbnailState == .visibleForTrayShow)
                ? gridModel.selectedTabGroupFrame.offsetBy(dx: 0, dy: -transitionTopPadding)
                : gridModel.selectedCardFrame.offsetBy(dx: 0, dy: -transitionTopPadding))
    }

    var body: some View {
        Group {
            if let selectedCardDetails = selectedCardDetails {
                Card(
                    details: selectedCardDetails, showsSelection: !gridModel.isHidden,
                    animate: true,
                    reportFrame: false
                )
                .runAfter(
                    toggling: gridModel.isHidden,
                    fromTrueToFalse: {
                        gridModel.animationThumbnailState = .hidden
                    },
                    fromFalseToTrue: {
                        gridModel.hideWithNoAnimation()
                        tabGroupModel.detailedTabGroup = nil
                    }
                )
                .frame(width: frame.width, height: frame.height)
                .offset(x: frame.origin.x, y: frame.origin.y)
                .frame(width: maxWidth, height: maxHeight, alignment: .topLeading)
                .allowsHitTesting(false)
                .clipped()
                .padding(.top, transitionTopPadding)
                .padding(.bottom, transitionBottomPadding)
                .ignoresSafeArea()
            } else {
                Color.clear
            }
        }
        .useEffect(deps: gridModel.animationThumbnailState) { _ in
            switch gridModel.animationThumbnailState {
            case .visibleForTrayShow:
                withAnimation(animation) {
                    gridModel.isHidden = false
                }
            case .visibleForTrayHidden:
                withAnimation(animation) {
                    gridModel.isHidden = true
                }
            case .hidden:
                break
            }
        }
    }
}
