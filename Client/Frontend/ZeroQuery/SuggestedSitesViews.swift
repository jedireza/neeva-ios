// Copyright Neeva. All rights reserved.

import Shared
import Storage
import SwiftUI

private enum SuggestedSiteUX {
    static let FaviconSize: CGFloat = 28
    static let HomeIconSize: CGFloat = 20
    static let IconSize: CGFloat = 40
    static let PinIconSize: CGFloat = 12
    static let IconCornerRadius: CGFloat = 4
    static let BlockSize: CGFloat = 64
    static let BlockSpacing: CGFloat = 24
}

struct SuggestedNavigationView<Content: View>: View {
    let url: URL
    let isPinnedSite: Bool!
    let title: () -> String
    let icon: () -> Content

    @Environment(\.onOpenURL) private var openURL

    var hint: String {
        let pinned = isPinnedSite ? "Pinned " : ""
        return pinned + "Suggested Site"
    }

    var body: some View {
        Button(action: { openURL(url) }) {
            VStack(spacing: 2) {
                icon()
                    .frame(
                        width: SuggestedSiteUX.IconSize, height: SuggestedSiteUX.IconSize,
                        alignment: .center
                    )
                    .background(Color(light: .ui.gray97, dark: .systemFill))
                    .cornerRadius(SuggestedSiteUX.IconCornerRadius)
                HStack {
                    if isPinnedSite {
                        Image("pin_small").renderingMode(.template).foregroundColor(Color.ui.gray60)
                            .frame(
                                width: SuggestedSiteUX.PinIconSize,
                                height: SuggestedSiteUX.PinIconSize, alignment: .center)
                    }
                    Text(title())
                        .withFont(.bodyMedium)
                        .lineLimit(1)
                        .background(
                            RoundedRectangle(cornerRadius: 4).fill(Color.background).padding(-4)
                        )
                        .padding(.top, 4)
                        .foregroundColor(.secondaryLabel)
                }
                .contentShape(Rectangle())
            }
            .frame(width: SuggestedSiteUX.BlockSize, height: SuggestedSiteUX.BlockSize)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title())
            .accessibilityHint(hint)
        }
        .onDrag { NSItemProvider(url: url) }
    }
}

struct SuggestedHomeView: View {
    let title = "Home"

    var body: some View {
        SuggestedNavigationView(
            url: NeevaConstants.appHomeURL, isPinnedSite: false,
            title: {
                title
            },
            icon: {
                Symbol(.house, size: SuggestedSiteUX.HomeIconSize, label: "Home")
                    .accentColor(.ui.adaptive.blue)
            }
        )
        .contextMenu {
            ZeroQueryCommonContextMenuActions(
                siteURL: NeevaConstants.appHomeURL,
                title: title,
                description: "Neeva Home",
                showOpenInIncognito: false)
        }
    }
}

struct SuggestedSiteView: View {
    let site: Site!
    let isPinnedSite: Bool!

    @Environment(\.onOpenURL) private var openURL
    @Environment(\.zeroQueryHideTopSite) private var zeroQueryHideTopSite

    @State private var isDeleting = false

    var title: String {
        if let provider = site.metadata?.providerName {
            return provider.capitalized
        } else {
            return site.tileURL.shortDisplayString.capitalized
        }
    }

    var body: some View {
        SuggestedNavigationView(
            url: site.url, isPinnedSite: isPinnedSite, title: { title },
            icon: {
                FaviconView(
                    url: site.url, icon: site.icon, size: SuggestedSiteUX.FaviconSize,
                    bordered: false
                )
            }
        )
        .actionSheet(isPresented: $isDeleting) {
            ActionSheet(
                title: Text("Permanently remove \(title) from Suggested Sites?"),
                buttons: [
                    .destructive(Text("Remove")) { zeroQueryHideTopSite(site) },
                    .cancel(),
                ])
        }
        .contextMenu {
            ZeroQueryCommonContextMenuActions(
                siteURL: site.url.absoluteURL,
                title: title,
                description: site.metadata?.description)
            // TODO: make this red
            Button(action: { isDeleting = true }) {
                Label("Remove", systemSymbol: .trash)
            }.foregroundColor(.red)
            if FeatureFlag[.pinToTopSites] {
                Text("Pin/unpin not yet implemented")
            }
        }
    }
}

struct SuggestedSitesView: View {
    let isExpanded: Bool
    @EnvironmentObject private var viewModel: SuggestedSitesViewModel
    @Environment(\.zeroQueryWidth) private var zeroQueryWidth
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var columnCount: Int {
        guard verticalSizeClass == .compact || horizontalSizeClass == .regular else {
            return 4
        }

        var columnCount = 0
        var excessSpace = zeroQueryWidth + SuggestedSiteUX.BlockSpacing
        while excessSpace > 0 {
            excessSpace -= SuggestedSiteUX.BlockSize + SuggestedSiteUX.BlockSpacing
            if excessSpace > 0 {
                columnCount += 1
            }
        }
        return columnCount
    }

    var body: some View {
        let columns = Array(
            repeating: GridItem(
                .fixed(SuggestedSiteUX.BlockSize), spacing: SuggestedSiteUX.BlockSpacing),
            count: columnCount)
        if isExpanded {
            LazyVGrid(columns: columns, alignment: .leading, spacing: SuggestedSiteUX.BlockSpacing)
            {
                if FeatureFlag[.homeAsSuggestedSite] {
                    SuggestedHomeView()
                }
                ForEach(viewModel.sites, id: \.self) { suggestedSite in
                    SuggestedSiteView(
                        site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite
                    )
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, ZeroQueryUX.Padding - 2)
        } else {
            FadingHorizontalScrollView { size in
                HStack(spacing: 0) {
                    if FeatureFlag[.homeAsSuggestedSite] {
                        SuggestedHomeView()
                    }
                    ForEach(Array(viewModel.sites.enumerated()), id: \.0) { i, suggestedSite in
                        Spacer().frame(width: SuggestedSiteUX.BlockSpacing)
                        SuggestedSiteView(
                            site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite
                        )
                    }
                }
                .frame(height: SuggestedSiteUX.BlockSize)
                .padding(.vertical, 10)
                .padding(.horizontal, ZeroQueryUX.Padding - 2)
                .fixedSize()
            }.frame(height: SuggestedSiteUX.BlockSize + 20)
        }
    }
}

#if DEBUG
    struct SuggestedSitesViews_Previews: PreviewProvider {
        static var previews: some View {
            HStack {
                SuggestedSiteView(
                    site: .init(url: "https://example.com", title: "Example", id: 1),
                    isPinnedSite: false)
                SuggestedSiteView(
                    site: .init(url: "https://twitter.com", title: "Twitter", id: 2),
                    isPinnedSite: true)
                SuggestedSiteView(
                    site: .init(url: "https://google.com", title: "Google", id: 3),
                    isPinnedSite: true)
                SuggestedSiteView(
                    site: .init(url: "https://youtube.com", title: "Youtube", id: 4),
                    isPinnedSite: true)
                SuggestedSiteView(
                    site: .init(url: "https://nba.com", title: "NBA", id: 5),
                    isPinnedSite: true)
                SuggestedSiteView(
                    site: .init(url: "https://mlb.com", title: "MLB", id: 6),
                    isPinnedSite: true)
            }.padding().previewLayout(.sizeThatFits)
            Group {
                SuggestedSitesView(isExpanded: false)
                SuggestedSitesView(isExpanded: true)
            }
            .previewLayout(.sizeThatFits)
            .environment(\.zeroQueryWidth, 375)
            .environmentObject(SuggestedSitesViewModel.preview)
        }
    }
#endif
