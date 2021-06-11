// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage

struct SuggestedSiteView: View {
    let site: Site!
    let isPinnedSite: Bool!

    @EnvironmentObject private var viewModel: SuggestedSitesViewModel

    @Environment(\.onOpenURL) private var openURL
    @Environment(\.shareURL) private var shareURL
    @Environment(\.openInNewTab) private var openInNewTab
    @Environment(\.hideTopSite) private var hideTopSite

    @State private var isDeleting = false

    var title: String {
        if let provider = site.metadata?.providerName {
            return provider.capitalized
        } else {
            return site.tileURL.shortDisplayString.capitalized
        }
    }

    var hint: String {
        let pinned = isPinnedSite ? "Pinned " : ""
        return pinned + "Suggested Site"
    }

    var body: some View {
        Button(action: { site.url.asURL.map(openURL) }) {
            VStack(spacing: 2) {
                FaviconView(site: site, size: NeevaHomeUX.FaviconSize, bordered: false)
                    .frame(width: NeevaHomeUX.SuggestedSiteIconSize, height: NeevaHomeUX.SuggestedSiteIconSize, alignment: .center)
                    .background(Color.neeva.ui.fixed.gray97)
                    .clipShape(RoundedRectangle(cornerRadius: NeevaHomeUX.SuggestedSiteIconCornerRadius))
                HStack {
                    if isPinnedSite {
                        Image("pin_small").renderingMode(.template).foregroundColor(Color.neeva.ui.gray60)
                            .frame(width: NeevaHomeUX.PinIconSize, height: NeevaHomeUX.PinIconSize, alignment: .center)
                    }
                    Text(title).lineLimit(1)
                        .font(Font(UIFont.systemFont(ofSize: NeevaHomeUX.SuggestedSiteTitleFontSize, weight: UIFont.Weight.regular)))
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.background).padding(-4))
                        .padding(.top, 4)
                        .foregroundColor(.secondaryLabel)
                }
                .contentShape(Rectangle())
            }
            .frame(width: NeevaHomeUX.SuggestedSiteBlockWidth, height: NeevaHomeUX.SuggestedSiteBlockHeight)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityHint(hint)
            .contextMenu(ContextMenu(menuItems: {
                Text(site.title.isEmpty ? site.url : site.title)
                Divider()
                Button(action: { site.url.asURL.map { openInNewTab($0, false) } }) {
                    Label("Open in New Tab", systemSymbol: .plusSquare)
                }
                Button(action: { site.url.asURL.map { openInNewTab($0, true) } }) {
                    Label("Open in Incognito", image: "incognito")
                }
                Button(action: { site.url.asURL.map(shareURL) }) {
                    Label("Share", systemSymbol: .squareAndArrowUp)
                }
                // TODO: make this red
                Button(action: { isDeleting = true }) {
                    Label("Remove", systemSymbol: .trash)
                }.foregroundColor(.red)
                if FeatureFlag[.pinToTopSites] {
                    Text("Pin/unpin not yet implemented")
                }
            }))
            .actionSheet(isPresented: $isDeleting) {
                ActionSheet(title: Text("Permanently remove \(title) from Suggested Sites?"), buttons: [
                    .destructive(Text("Remove")) { hideTopSite(site) },
                    .cancel()
                ])
            }
        }
    }
}

struct SuggestedSitesView: View {
    let isExpanded: Bool
    @EnvironmentObject private var viewModel: SuggestedSitesViewModel

    var columns:[GridItem] {
        [GridItem(.fixed(NeevaHomeUX.SuggestedSiteBlockWidth), spacing:
                    NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)),
        GridItem(.fixed(NeevaHomeUX.SuggestedSiteBlockWidth),spacing:
                    NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)),
        GridItem(.fixed(NeevaHomeUX.SuggestedSiteBlockWidth),spacing:
                    NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)),
        GridItem(.fixed(NeevaHomeUX.SuggestedSiteBlockWidth))]
    }

    var isTabletOrLandscape: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.orientation.isLandscape
    }

    func spacerWidth(from screenWidth: CGFloat) -> CGFloat {
        (
           (screenWidth - (NeevaHomeUX.HeaderPadding - 2) * 2)
               - NeevaHomeUX.SuggestedSiteBlockWidth * (isTabletOrLandscape ? 8 : 4)
       ) / (isTabletOrLandscape ? 7 : 3)
    }

    var body: some View {
        if isExpanded && !isTabletOrLandscape {
            VStack(spacing: NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)) {
                HStack {
                    ForEach(Array(viewModel.sites.prefix(4).enumerated()), id: \.0) { i, suggestedSite in
                        if i != 0 {
                            Spacer()
                        }
                        SuggestedSiteView(site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite)
                    }
                }
                if viewModel.sites.count > 4 {
                    HStack {
                        ForEach(Array(viewModel.sites.dropFirst(4).enumerated()), id: \.0) { i, suggestedSite in
                            if i != 0 {
                                Spacer()
                            }
                            SuggestedSiteView(site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, NeevaHomeUX.HeaderPadding - 2)
        } else {
            FadingHorizontalScrollView { size in
                HStack(spacing: 0) {
                    let spacerWidth = spacerWidth(from: size.width)
                    ForEach(Array(viewModel.sites.enumerated()), id: \.0) { i, suggestedSite in
                        if i > 0, spacerWidth > 0 {
                            Spacer().frame(width: spacerWidth)
                        }
                        SuggestedSiteView(site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite)
                    }
                }
                .frame(height: NeevaHomeUX.SuggestedSiteBlockHeight)
                .padding(.vertical, 10)
                .padding(.horizontal, NeevaHomeUX.HeaderPadding - 2)
                .fixedSize()
            }.frame(height: NeevaHomeUX.SuggestedSiteBlockHeight + 20)
        }
    }
}

#if DEV
struct SuggestedSitesViews_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            SuggestedSiteView(site: .init(url: "https://example.com", title: "Example", id: 1), isPinnedSite: false)
            SuggestedSiteView(site: .init(url: "https://google.com", title: "Google", id: 2), isPinnedSite: true)
        }.padding().previewLayout(.sizeThatFits)
        Group {
            SuggestedSitesView(isExpanded: false)
            SuggestedSitesView(isExpanded: true)
        }.previewLayout(.sizeThatFits).environmentObject(SuggestedSitesViewModel.preview)
    }
}
#endif
