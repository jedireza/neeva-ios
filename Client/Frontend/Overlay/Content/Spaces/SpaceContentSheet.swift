// Copyright Neeva. All rights reserved.

import Combine
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum SpaceContentSheetUX {
    static let PeekHeight: CGFloat = 120
    static let SpaceInfoThumbnailSize: CGFloat = 36
}

struct SpaceContentSheet: View {
    @ObservedObject var model: SpaceContentSheetModel
    @ObservedObject var scrollingController: TabScrollingController
    let overlayModel: OverlaySheetModel = OverlaySheetModel()

    init(model: SpaceContentSheetModel, scrollingController: TabScrollingController) {
        self.model = model
        self.scrollingController = scrollingController
    }

    var body: some View {
        if let _ = model.currentSpaceEntityDetail {
            GeometryReader { geom in
                OverlaySheetView(model: overlayModel, style: .spaces, onDismiss: {}) {
                    VStack {
                        SpacePageContent(model: model)
                        Spacer()
                    }
                }
                .clipped()
                .shadow(radius: 2)
                .offset(
                    x: 0,
                    y: -geom.size.height * scrollingController.headerTopOffset
                        / scrollingController.headerHeight
                )
                .animation(.easeInOut)
                .onAppear {
                    DispatchQueue.main.async {
                        overlayModel.peekHeight = SpaceContentSheetUX.PeekHeight
                        overlayModel.show()
                    }
                }
            }
        }
    }
}

struct SpacePageContent: View {
    @ObservedObject var model: SpaceContentSheetModel

    var body: some View {
        VStack {
            SpacePageSummary(details: model.currentSpaceEntityDetail)
                .frame(height: SpaceContentSheetUX.PeekHeight)
            Color.ui.adaptive.separator.frame(height: 1)
            HStack {
                Text("Comments")
                    .withFont(.headingSmall)
                    .foregroundColor(.label)
                Spacer()
                Button(action: {
                    model.addingComment = true
                }) {
                    Text("Add")
                        .withFont(.bodyMedium)
                        .foregroundColor(.ui.adaptive.blue)
                }
            }
            if let comments = model.comments {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(comments, id: \.id) { comment in
                            CommentView(comment: comment)
                        }
                        ForEach(model.addedComments, id: \.id) { comment in
                            CommentView(comment: comment)
                        }
                        if model.addingComment {
                            AddCommentView(
                                commentText: $model.commentAdded,
                                editing: $model.addingComment
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    Color.ui.adaptive.separator.frame(height: 1)
                }
            }
        }.padding(.horizontal, 16)
    }
}

struct SpacePageSummary: View {
    let details: SpaceEntityThumbnail?

    var body: some View {
        if let details = details {
            VStack(spacing: 7) {
                HStack(spacing: 12) {
                    Text(details.title)
                        .withFont(.headingMedium)
                        .lineLimit(2)
                        .foregroundColor(.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    details.thumbnail.frame(
                        width: SpaceContentSheetUX.SpaceInfoThumbnailSize,
                        height: SpaceContentSheetUX.SpaceInfoThumbnailSize
                    )
                    .cornerRadius(DetailsViewUX.ThumbnailCornerRadius)
                }
                if let snippet = details.description {
                    Text(snippet)
                        .withFont(.bodySmall)
                        .lineLimit(3)
                        .foregroundColor(.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(.bottom, 20)
        }
    }
}

struct AddCommentView: View {
    @Binding var commentText: String
    @Binding var editing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                CompactProfileView(
                    pictureURL: NeevaUserInfo.shared.pictureUrl ?? "",
                    displayName: NeevaUserInfo.shared.displayName!)
                Text("Now")
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
                Spacer()
            }
            TextField(
                "What's on your mind?", text: $commentText,
                onCommit: {
                    editing = false
                }
            )
            .withFont(unkerned: .bodyMedium)
            .foregroundColor(.label)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.quaternarySystemFill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity)
        .introspectTextField { textField in
            textField.becomeFirstResponder()
        }
    }
}

struct CommentView: View {
    let comment: SpaceCommentData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                CompactProfileView(
                    pictureURL: comment.profile.pictureUrl,
                    displayName: comment.profile.displayName)
                Text(comment.formattedRelativeTime)
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
                Spacer()
            }
            Text(comment.comment)
                .withFont(.bodyMedium)
                .foregroundColor(.label)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.quaternarySystemFill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity)
    }
}

struct CompactProfileView: View {
    let pictureURL: String
    let displayName: String

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if let pictureUrl = URL(string: pictureURL) {
                    WebImage(url: pictureUrl).resizable()
                } else {
                    let name = (displayName).prefix(2).uppercased()
                    Color.brand.blue
                        .overlay(
                            Text(name)
                                .accessibilityHidden(true)
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                        )
                }
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .frame(width: 20, height: 20)
            Text(displayName)
                .withFont(.bodyMedium)
                .lineLimit(1)
                .foregroundColor(Color.label)
        }
    }
}
