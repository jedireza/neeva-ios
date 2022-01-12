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

    @Namespace var cardGroup

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
        .background(Color.secondarySystemFill)
        .cornerRadius(
            24,
            corners: groupDetails.allDetails.count <= 2 || groupDetails.isShowingDetails ? .all : .leading
        )
    }

    private var header: some View {
        HStack {
            Symbol(decorative: .squareGrid2x2Fill)
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

    private var scrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(
                spacing: SingleLevelTabCardsViewUX.TabGroupCarouselTabSpacing
            ) {
                ForEach(groupDetails.allDetails) { childTabDetail in
                    FittedCard(details: childTabDetail, dragToClose: false)
                        .animation(.spring())
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
        }
    }

    private var grid: some View {
        LazyVStack(alignment: .leading, spacing: CardGridUX.GridSpacing) {
            ForEach(Array(groupDetails.allDetails.split(intoChunksOf: 2).enumerated()), id: \.offset) { (_, row) in
                HStack(spacing: CardGridUX.GridSpacing) {
                    ForEach(row) { childTabDetail in
                        FittedCard(details: childTabDetail, dragToClose: false)
                            .animation(.spring())
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
