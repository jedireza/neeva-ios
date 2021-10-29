// Copyright Neeva. All rights reserved.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

struct SpaceEntityDetailView: View {
    @Default(.showDescriptions) var showDescriptions
    @EnvironmentObject var tabCardModel: TabCardModel
    let details: SpaceEntityThumbnail
    let onSelected: () -> Void
    let addToAnotherSpace: (URL, String?, String?) -> Void
    let editSpaceItem: () -> Void
    let index: Int

    var socialURL: URL? {
        guard SocialInfoType(rawValue: details.data.url?.baseDomain ?? "") != nil else {
            return nil
        }

        return details.data.url
    }

    @State private var isPressed: Bool = false
    @State private var isPreviewActive: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if index > 0 {
                Color.TrayBackground.frame(height: 2).edgesIgnoringSafeArea(.top)
                Spacer(minLength: 0)
            }

            let entityDetailView = Button {
                onSelected()
                ClientLogger.shared.logCounter(
                    .SpacesDetailEntityClicked,
                    attributes: getLogCounterAttributesForSpaceEntities(details: details))
            } label: {
                if details.isImage, let url = details.data.url {
                    VStack(spacing: 0) {
                        WebImage(url: url).resizable()
                            .transition(.fade(duration: 0.5))
                            .background(Color.white)
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(DetailsViewUX.ThumbnailCornerRadius)
                            .padding(.bottom, 8)
                        if !details.title.isEmpty {
                            Text(details.title)
                                .withFont(.bodyMedium)
                                .lineLimit(1)
                                .foregroundColor(Color.label)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if let recipe = details.data.recipe {
                    RecipeBanner(recipe: recipe)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: DetailsViewUX.ItemPadding) {
                        HStack(spacing: DetailsViewUX.ItemPadding) {
                            details.thumbnail.frame(
                                width: DetailsViewUX.ThumbnailSize,
                                height: DetailsViewUX.ThumbnailSize
                            )
                            .cornerRadius(DetailsViewUX.ThumbnailCornerRadius)
                            VStack(spacing: DetailsViewUX.Padding) {
                                HStack(spacing: 6) {
                                    if let socialURL = socialURL {
                                        FaviconView(forSiteUrl: socialURL)
                                            .frame(width: 12, height: 12)
                                            .cornerRadius(4)
                                    }
                                    Text(details.data.richEntity?.title ?? details.title)
                                        .withFont(.bodyMedium)
                                        .lineLimit(2)
                                        .foregroundColor(Color.label)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                if let snippet = details.data.richEntity?.description
                                    ?? details.description, !showDescriptions
                                {
                                    Text(snippet)
                                        .withFont(.bodySmall)
                                        .lineLimit(2)
                                        .foregroundColor(Color.secondaryLabel)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        if let snippet = details.data.richEntity?.description
                            ?? details.description, showDescriptions
                        {
                            Text(snippet)
                                .withFont(.bodySmall)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(Color.secondaryLabel)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }.buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
                .padding()
                .background(Color.DefaultBackground)

            if let url = details.richEntityPreviewURL {
                NavigationLink(
                    isActive: $isPreviewActive,
                    destination: {
                        WebViewContainer(
                            webView: {
                                let wv = WKWebView(
                                    frame: CGRect.zero,
                                    configuration:
                                        tabCardModel.manager.selectedTab?
                                        .webView?.configuration
                                        ?? WKWebViewConfiguration())
                                wv.load(URLRequest(url: url))
                                return wv
                            }()
                        ).cornerRadius(16).navigationBarHidden(true)
                            .highPriorityGesture(
                                TapGesture()
                                    .onEnded({
                                        isPreviewActive = false
                                    }))
                    }
                ) {
                    HStack {
                        entityDetailView
                        Text("Preview")
                            .withFont(.bodyMedium)
                            .foregroundColor(.secondaryLabel)
                    }
                }.padding(.trailing, 6)
            } else {
                entityDetailView
            }

            Spacer(minLength: 0)
        }.scaleEffect(isPressed ? 0.95 : 1)
            .contextMenu(
                ContextMenu(menuItems: {
                    if details.ACL >= .edit {
                        Button(
                            action: {
                                editSpaceItem()
                            },
                            label: {
                                Label("Edit item", systemSymbol: .squareAndPencil)
                            })
                    }
                    Button(
                        action: {
                            addToAnotherSpace(
                                (details.data.url)!,
                                details.title, details.description)
                        },
                        label: {
                            Label("Add to another Space", systemSymbol: .docOnDoc)
                        })
                })
            )
            .accessibilityLabel(details.title)
            .accessibilityHint("Space Item")
    }
}

private func getLogCounterAttributesForSpaceEntities(details: SpaceEntityThumbnail?)
    -> [ClientLogCounterAttribute]
{
    var attributes = EnvironmentHelper.shared.getAttributes()
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.isPublic,
            value: String(details?.manager.isPublic ?? false)))
    if details?.isSharedPublic == true {
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SpacesAttribute.spaceID,
                value: String(details?.spaceID ?? "")))
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SpacesAttribute.spaceEntityID,
                value: String(details?.id ?? "")))
    }
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.isShared,
            value: String(details?.manager.isShared ?? false)))
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.numberOfSpaceEntities,
            value: String(details?.manager.contentData?.count ?? 1)
        )

    )
    return attributes
}
