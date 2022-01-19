// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CollapsableCardGroupView: View {
    let groupDetails: TabGroupCardDetails
    let containerGeometry: GeometryProxy

    @Environment(\.aspectRatio) private var aspectRatio
    @Environment(\.cardSize) private var size
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var tabGroupCardModel: TabGroupCardModel

    @State private var frame = CGRect.zero

    @Namespace var cardGroup

    var groupFromSpace: Bool {
        return groupDetails.id
            == tabGroupCardModel.manager.get(for: groupDetails.id)?.children.first?.parentSpaceID
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if groupDetails.isShowingDetails {
                grid
            } else {
                scrollView
            }
        }
        .animation(.spring(), value: groupDetails.isShowingDetails)
        .transition(.fade)
        .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding)
        .background(
            Color.secondarySystemFill
                .cornerRadius(
                    24,
                    corners: groupDetails.allDetails.count <= 2 || groupDetails.isShowingDetails
                        ? .all : .leading
                )
        )
    }

    private var header: some View {
        HStack {
            Symbol(decorative: groupFromSpace ? .bookmarkFill : .squareGrid2x2Fill)
                .foregroundColor(.label)
            Text(groupDetails.title)
                .withFont(.labelLarge)
                .foregroundColor(.label)
            Spacer()
            Button {
                groupDetails.isShowingDetails.toggle()
            } label: {
                Label("caret", systemImage: "chevron.up")
                    .foregroundColor(.label)
                    .labelStyle(.iconOnly)
                    .rotationEffect(
                        .degrees(groupDetails.isShowingDetails ? -180 : 0)
                    )
                    .padding()
            }
        }.padding(.leading, CardGridUX.GridSpacing).frame(
            height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
    }

    @ViewBuilder
    private var scrollView: some View {
        // ScrollView clips child views by default, so here ScrollView is resized
        // to make CardTransitionModifier visible. TopSpace and BottomSpace are
        // paddings needed to make ScrollView look in place when it's resized.
        let topSpace =
            browserModel.cardTransition == .hidden
            ? 0 : self.frame.minY - containerGeometry.frame(in: .global).minY
        let bottomSpace =
            browserModel.cardTransition == .hidden
            ? 0 : containerGeometry.frame(in: .global).maxY - self.frame.maxY

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(
                spacing: SingleLevelTabCardsViewUX.TabGroupCarouselTabSpacing
            ) {
                ForEach(groupDetails.allDetails) { childTabDetail in
                    FittedCard(details: childTabDetail, dragToClose: false)
                        .matchedGeometryEffect(id: childTabDetail.id, in: cardGroup)
                        .modifier(
                            CardTransitionModifier(
                                details: childTabDetail,
                                containerGeometry: containerGeometry)
                        )
                }
            }
            .padding(.leading, CardGridUX.GridSpacing)
            .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)
            .padding(
                .bottom, SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
            )
            .background(
                GeometryReader { geom in
                    Color.clear.useEffect(deps: geom.frame(in: .global)) { frame in
                        self.frame = frame
                    }
                }
            )
            .padding(.top, topSpace)
            .padding(.bottom, bottomSpace)
        }
        .padding(.top, -topSpace)
        .padding(.bottom, -bottomSpace)
    }

    private var grid: some View {
        LazyVStack(alignment: .leading, spacing: CardGridUX.GridSpacing) {
            ForEach(
                Array(groupDetails.allDetails.split(intoChunksOf: 2).enumerated()), id: \.offset
            ) { (_, row) in
                HStack(spacing: CardGridUX.GridSpacing) {
                    ForEach(row) { childTabDetail in
                        FittedCard(details: childTabDetail, dragToClose: false)
                            .matchedGeometryEffect(id: childTabDetail.id, in: cardGroup)
                            .modifier(
                                CardTransitionModifier(
                                    details: childTabDetail,
                                    containerGeometry: containerGeometry)
                            )
                    }
                }
            }
        }
        .padding(.leading, CardGridUX.GridSpacing)
        .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)
        .padding(
            .bottom, SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
        )
    }
}
