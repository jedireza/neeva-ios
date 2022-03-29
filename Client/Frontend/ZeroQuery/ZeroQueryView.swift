// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import Storage
import SwiftUI
import WalletCore

public struct ZeroQueryUX {
    fileprivate static let ToggleButtonSize: CGFloat = 32
    fileprivate static let ToggleIconSize: CGFloat = 14
    static let Padding: CGFloat = 16
}

extension EnvironmentValues {
    private struct ZeroQueryWidthKey: EnvironmentKey {
        static let defaultValue: CGFloat = 0
    }
    /// The width of the zero query view, in points.
    var zeroQueryWidth: CGFloat {
        get { self[ZeroQueryWidthKey.self] }
        set { self[ZeroQueryWidthKey.self] = newValue }
    }
}

private enum TriState: Int, Codable {
    case hidden
    case compact
    case expanded

    var verb: String {
        switch self {
        case .hidden: return "shows"
        case .compact: return "expands"
        case .expanded: return "hides"
        }
    }

    var icon: Nicon {
        switch self {
        case .hidden: return .chevronDown
        case .compact: return .doubleChevronDown
        case .expanded: return .chevronUp
        }
    }

    var next: TriState {
        switch self {
        case .hidden: return .compact
        case .compact: return .expanded
        case .expanded: return .hidden
        }
    }

    mutating func advance() {
        self = self.next
    }
}

extension Defaults.Keys {
    fileprivate static let expandSuggestedSites = Defaults.Key<TriState>(
        "profile.home.suggestedSites.expanded",
        default: FeatureFlag[.web3Mode] ? .expanded : .compact
    )
    fileprivate static let expandSearches = Defaults.Key<Bool>(
        "profile.home.searches.expanded", default: true)
    fileprivate static let expandSpaces = Defaults.Key<Bool>(
        "profile.home.spaces.expanded", default: true)
    fileprivate static let expandSuggestedSpace = Defaults.Key<Bool>(
        "profile.home.suggestedSpace.expanded", default: true)
}

struct ZeroQueryHeader: View {
    let title: LocalizedStringKey
    let action: () -> Void
    let label: LocalizedStringKey
    let icon: Nicon

    var body: some View {
        HStack {
            Text(title)
                .withFont(.headingMedium)
                .foregroundColor(.secondaryLabel)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer()
            Button(action: action) {
                // decorative because the toggle action is expressed on the header view itself.
                // This button is not an accessibility element.
                Symbol(decorative: icon, size: ZeroQueryUX.ToggleIconSize, weight: .medium)
                    .frame(
                        width: ZeroQueryUX.ToggleButtonSize, height: ZeroQueryUX.ToggleButtonSize,
                        alignment: .center
                    )
                    .background(Color(light: .ui.gray98, dark: .systemFill)).clipShape(Circle())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits([.isHeader, .isButton])
        .accessibilityLabel("\(Text(title)), \(Text(label))")
        .accessibilityAction(.default, action)
        .padding([.top, .horizontal], ZeroQueryUX.Padding)
    }
}

struct ZeroQueryPlaceholder: View {
    let label: LocalizedStringKey

    var body: some View {
        HStack {
            Spacer()
            Text(label)
                .withFont(.bodyMedium)
                .multilineTextAlignment(.center)
            Spacer()
        }.padding(.vertical, 12)
    }
}

struct ZeroQueryView: View {
    @EnvironmentObject var viewModel: ZeroQueryModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Default(.expandSuggestedSites) private var expandSuggestedSites
    @Default(.expandSearches) private var expandSearches
    @Default(.expandSpaces) private var expandSpaces
    @Default(.expandSuggestedSpace) private var expandSuggestedSpace
    @Default(.cryptoPublicKey) private var cryptoPublicKey: String

    @State var url: URL?
    @State var tab: Tab?

    func ratingsCard(_ viewWidth: CGFloat) -> some View {
        RatingsCard(
            onClose: {
                viewModel.showRatingsCard = false
                Defaults[.ratingsCardHidden] = true
                UserFlagStore.shared.setFlag(
                    .dismissedRatingPromo,
                    action: {})
            },
            onFeedback: {
                showFeedbackPanel(bvc: viewModel.bvc, shareURL: false)
            },
            viewWidth: viewWidth
        )
        .modifier(
            ImpressionLoggerModifier(
                path: .PromoCardAppear,
                attributes: EnvironmentHelper.shared.getAttributes()
                    + [
                        ClientLogCounterAttribute(
                            key: LogConfig.PromoCardAttribute
                                .promoCardType,
                            value: "RatingCard"
                        )
                    ]
            )
        )
    }

    func isLandScape() -> Bool {
        return horizontalSizeClass == .regular
            || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }

    var suggestedSpace: some View {
        RecommendedSpacesView(
            store: SpaceStore.suggested,
            viewModel: viewModel,
            expandSuggestedSpace: $expandSuggestedSpace
        )
    }

    var body: some View {
        GeometryReader { geom in
            ScrollView {
                VStack(spacing: 0) {
                    if let searchQuery = viewModel.searchQuery, let url = url {
                        SearchSuggestionView(
                            Suggestion.editCurrentQuery(searchQuery, url)
                        )
                        .environmentObject(viewModel.bvc.suggestionModel)

                        SuggestionsDivider(height: 8)
                    } else if let openTab = tab {
                        SearchSuggestionView(
                            Suggestion.editCurrentURL(
                                TabCardDetails(
                                    tab: openTab,
                                    manager: viewModel.bvc.tabManager)
                            )
                        )
                        .environmentObject(viewModel.bvc.suggestionModel)

                        SuggestionsDivider(height: 8)
                    }

                    if viewModel.isIncognito {
                        IncognitoDescriptionView().clipShape(RoundedRectangle(cornerRadius: 12.0))
                            .padding(ZeroQueryUX.Padding)
                    } else {
                        if let promoCardType = viewModel.promoCard {
                            PromoCard(type: promoCardType, viewWidth: geom.size.width)
                                .modifier(
                                    ImpressionLoggerModifier(
                                        path: .PromoCardAppear,
                                        attributes: EnvironmentHelper.shared.getAttributes()
                                            + [
                                                ClientLogCounterAttribute(
                                                    key: LogConfig.PromoCardAttribute
                                                        .promoCardType,
                                                    value: viewModel.promoCard?.name ?? "None"
                                                )
                                            ]
                                    )
                                )
                        }

                        if isLandScape() && viewModel.showRatingsCard {
                            ratingsCard(geom.size.width)
                        }

                        if !SpaceStore.suggested.allSpaces.isEmpty,
                            expandSuggestedSpace
                        {
                            suggestedSpace
                        }

                        if Defaults[.signedInOnce] || FeatureFlag[.web3Mode] {
                            ZeroQueryHeader(
                                title: "Suggested sites",
                                action: { expandSuggestedSites.advance() },
                                label: "\(expandSuggestedSites.verb) this section",
                                icon: expandSuggestedSites.icon
                            )

                            if expandSuggestedSites != .hidden {
                                SuggestedSitesView(
                                    isExpanded: expandSuggestedSites == .expanded,
                                    viewModel: viewModel.suggestedSitesViewModel)
                            }

                            if !isLandScape() && viewModel.showRatingsCard {
                                ratingsCard(geom.size.width)
                            }
                        }

                        ZeroQueryHeader(
                            title: "Searches",
                            action: { expandSearches.toggle() },
                            label: "\(expandSearches ? "hides" : "shows") this section",
                            icon: expandSearches ? .chevronUp : .chevronDown
                        )

                        if expandSearches {
                            if !Defaults[.signedInOnce] {
                                if FeatureFlag[.web3Mode] {
                                    SuggestedXYZSearchesView()
                                        .onChange(of: cryptoPublicKey) { _ in
                                            viewModel.updateState()
                                        }
                                } else {
                                    SuggestedPreviewSearchesView()
                                }
                            } else {
                                SuggestedSearchesView()
                            }
                        }

                        if NeevaUserInfo.shared.isUserLoggedIn && Defaults[.signedInOnce] {
                            ZeroQueryHeader(
                                title: "Spaces",
                                action: { expandSpaces.toggle() },
                                label: "\(expandSpaces ? "hides" : "shows") this section",
                                icon: expandSpaces ? .chevronUp : .chevronDown
                            )
                            if expandSpaces {
                                SuggestedSpacesView()
                            }
                        }

                        if !SpaceStore.suggested.allSpaces.isEmpty,
                            !expandSuggestedSpace
                        {
                            suggestedSpace
                        }
                    }

                    Spacer()
                }
            }
            .environment(\.zeroQueryWidth, geom.size.width)
            .animation(nil)
            .onAppear {
                url = viewModel.tabURL
                tab = viewModel.openedFrom?.openedTab
            }
        }
    }
}

struct RecommendedSpacesView: View {
    @ObservedObject var store: SpaceStore
    @ObservedObject var viewModel: ZeroQueryModel
    @Binding var expandSuggestedSpace: Bool

    var body: some View {
        if let space = store.allSpaces.first {
            ZeroQueryHeader(
                title: "\(space.name)",
                action: { expandSuggestedSpace.toggle() },
                label: "\(expandSuggestedSpace ? "hides" : "shows") this section",
                icon: expandSuggestedSpace ? .chevronUp : .chevronDown
            )
            if expandSuggestedSpace {
                CompactSpaceDetailList(
                    primitive: SpaceCardDetails(
                        space: space,
                        manager: SpaceStore.suggested)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .environment(
                    \.onOpenURLForSpace,
                    { url, _ in
                        if url.absoluteString.starts(
                            with: NeevaConstants.appSpacesURL.absoluteString),
                            let navPath = NavigationPath.navigationPath(
                                from: URL(
                                    string: NeevaConstants.appDeepLinkURL.absoluteString
                                        + "space?id="
                                        + url.lastPathComponent)!,
                                with: viewModel.bvc)
                        {
                            viewModel.bvc.hideZeroQuery()
                            NavigationPath.handle(nav: navPath, with: viewModel.bvc)
                        } else {
                            viewModel.bvc.tabManager.createOrSwitchToTab(
                                for: url)
                            viewModel.bvc.hideZeroQuery()
                        }
                    }
                )
                .environmentObject(viewModel.bvc.gridModel)
                .environmentObject(viewModel.bvc.gridModel.tabCardModel)
                .environmentObject(viewModel.bvc.gridModel.spaceCardModel)
            }
        }
    }
}

#if DEBUG
    struct ZeroQueryView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ZeroQueryView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(
                ZeroQueryModel(
                    bvc: SceneDelegate.getBVC(for: nil),
                    profile: BrowserProfile(localName: "profile"), shareURLHandler: { _, _ in })
            )
            .environmentObject(SuggestedSitesViewModel.preview)
            .environmentObject(
                SuggestedSearchesModel(
                    suggestedQueries: [
                        ("lebron james", .init(url: "https://neeva.com", title: "", guid: "1")),
                        ("neeva", .init(url: "https://neeva.com", title: "", guid: "2")),
                        ("knives out", .init(url: "https://neeva.com", title: "", guid: "3")),
                    ]
                )
            )
        }
    }
#endif
