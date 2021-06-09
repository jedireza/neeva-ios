// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared
import Defaults

struct NeevaHomeUX {
    static let FaviconSize: CGFloat = 28
    static let SuggestedSiteIconSize: CGFloat = 40
    static let SuggestedSiteIconCornerRadius: CGFloat = 4
    static let PinIconSize: CGFloat = 12
    static let SuggestedSiteTitleFontSize: CGFloat = 14
    static let SuggestedSiteBlockWidth: CGFloat = 64
    static let SuggestedSiteBlockHeight: CGFloat = 62
    static let ToggleButtonSize: CGFloat = 32
    static let ToggleIconSize: CGFloat = 14
    static let HeaderPadding: CGFloat = 16

    static func horizontalItemSpacing(isTabletOrLandscape: Bool) -> CGFloat {
        return isTabletOrLandscape ? 32 : 28
    }

    static func singleRowWidth(isTabletOrLandscape: Bool) -> CGFloat {
        let numItems: CGFloat = isTabletOrLandscape ? 8 : 4
        return numItems * SuggestedSiteBlockWidth
            + (numItems - 1) * horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)
            + 2 * HeaderPadding
    }
}

fileprivate enum TriState: Int, Codable {
    case hidden
    case compact
    case expanded

    var verb: String {
        switch self {
        case .hidden: return "show"
        case .compact: return "expand"
        case .expanded: return "hide"
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
    fileprivate static let expandSuggestedSites = Defaults.Key<TriState>("profile.home.suggestedSites.expanded", default: .compact)
    fileprivate static let expandSearches = Defaults.Key<Bool>("profile.home.searches.expanded", default: true)
    fileprivate static let expandSpaces = Defaults.Key<Bool>("profile.home.spaces.expanded", default: true)
}

struct NeevaHomeHeader: View {
    let title: String
    let action: () -> ()
    let label: String
    let icon: Nicon

    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        HStack {
            Text(title)
                .textCase(.uppercase)
                .foregroundColor(.secondaryLabel)
                .font(.roobert(.semibold, size: 13))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer()
            Button(action: action) {
                Symbol(icon, size: NeevaHomeUX.ToggleIconSize, weight: .medium)
                    .frame(width: NeevaHomeUX.ToggleButtonSize, height: NeevaHomeUX.ToggleButtonSize, alignment: .center)
                    .background(Color.Neeva.UI.Gray98).clipShape(Circle())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits([.isHeader])
        .accessibilityLabel(title)
        .accessibilityHint("Double-tap to \(label)")
        .accessibilityAction(.default, action)
        .padding([.top, .horizontal], NeevaHomeUX.HeaderPadding)
    }
}

struct NeevaHome: View {
    @ObservedObject var viewModel: HomeViewModel

    @Default(.expandSuggestedSites) private var expandSuggestedSites
    @Default(.expandSearches) private var expandSearches
    @Default(.expandSpaces) private var expandSpaces

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.isPrivate {
                    IncognitoDescriptionView().clipShape(RoundedRectangle(cornerRadius: 12.0)).padding(16.0)
                }
                if !viewModel.isPrivate && viewModel.showDefaultBrowserCard {
                    PromoCard(model: viewModel)
                }
                VStack(spacing: 0) {
                    NeevaHomeHeader(
                        title: "Suggested sites",
                        action: { expandSuggestedSites.advance() },
                        label: "\(expandSuggestedSites.verb) suggested sites",
                        icon: expandSuggestedSites.icon
                    )
                    if expandSuggestedSites != .hidden {
                        SuggestedSitesView(isExpanded: expandSuggestedSites == .expanded)
                    }

                    NeevaHomeHeader(
                        title: "Searches",
                        action: { expandSearches.toggle() },
                        label: "\(expandSearches ? "hide" : "show") searches",
                        icon: expandSearches ? .chevronUp : .chevronDown
                    )
                    if expandSearches {
                        SuggestedSearchesView()
                            .padding(.horizontal, NeevaHomeUX.HeaderPadding)
                    }
                }
                Spacer()
            }
        }
    }
}

#if DEV
struct NeevaHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NeevaHome(viewModel: HomeViewModel())
                .navigationBarTitleDisplayMode(.inline)
        }
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
