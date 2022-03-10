// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum SpaceContentSheetUX {
    static let SpaceInfoThumbnailSize: CGFloat = 48
}

struct SpaceContentSheet: View {
    @ObservedObject var model: SpaceContentSheetModel
    var yOffset: CGFloat

    init(model: SpaceContentSheetModel, yOffset: CGFloat) {
        self.model = model
        self.yOffset = yOffset
    }

    var body: some View {
        if let _ = model.currentSpaceEntityDetail {
            GeometryReader { geom in
                BottomSheetView(
                    peekContentHeight: SpaceContentSheetUX.SpaceInfoThumbnailSize, onDismiss: {}
                ) {
                    SpacePageContent(model: model)
                }
                .offset(
                    x: 0,
                    y: -geom.size.height * yOffset
                )
                .animation(.easeInOut)
            }
        }
    }
}

struct SpacePageContent: View {
    @ObservedObject var model: SpaceContentSheetModel

    var body: some View {
        VStack {
            SpacePageSummary(
                details: model.currentSpaceEntityDetail,
                spaceDetails: model.currentSpaceDetail)
            Spacer()
        }.padding(.horizontal, 16)
    }
}

struct SpacePageSummary: View {
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace
    let details: SpaceEntityThumbnail?
    let spaceDetails: SpaceCardDetails?

    var body: some View {
        if let details = details {
            VStack(spacing: 7) {
                if let spaceDetails = spaceDetails {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            ForEach(spaceDetails.allDetails, id: \.id) { entity in
                                if let url = entity.manager.get(for: entity.id)?
                                    .primitiveUrl
                                {
                                    Button(
                                        action: { onOpenURLForSpace(url, spaceDetails.id) },
                                        label: {
                                            entity.thumbnail.frame(
                                                width: SpaceContentSheetUX.SpaceInfoThumbnailSize
                                                    * (entity.id == details.id ? 1 : 0.8),
                                                height: SpaceContentSheetUX.SpaceInfoThumbnailSize
                                                    * (entity.id == details.id ? 1 : 0.8)
                                            ).cornerRadius(SpaceViewUX.ThumbnailCornerRadius)
                                        })
                                }
                            }
                        }
                    }
                } else {
                    details.thumbnail.frame(
                        width: SpaceContentSheetUX.SpaceInfoThumbnailSize,
                        height: SpaceContentSheetUX.SpaceInfoThumbnailSize
                    ).cornerRadius(SpaceViewUX.ThumbnailCornerRadius)

                }
            }.padding(.bottom, 20)
        }
    }
}
