// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared
import Defaults

public struct ZeroQueryUX {
    fileprivate static let ToggleButtonSize: CGFloat = 32
    fileprivate static let ToggleIconSize: CGFloat = 14
    static let Padding: CGFloat = 16
}

fileprivate enum TriState: Int, Codable {
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
    fileprivate static let expandSuggestedSites = Defaults.Key<TriState>("profile.home.suggestedSites.expanded", default: .compact)
    fileprivate static let expandSearches = Defaults.Key<Bool>("profile.home.searches.expanded", default: true)
    fileprivate static let expandSpaces = Defaults.Key<Bool>("profile.home.spaces.expanded", default: true)
}

struct ZeroQueryHeader: View {
    let title: String
    let action: () -> ()
    let label: String
    let icon: Nicon

    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        HStack {
            Text(title)
                .withFont(.headingMedium)
                .foregroundColor(.secondaryLabel)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer()
            Button(action: action) {
                Symbol(icon, size: ZeroQueryUX.ToggleIconSize, weight: .medium)
                    .frame(width: ZeroQueryUX.ToggleButtonSize, height: ZeroQueryUX.ToggleButtonSize, alignment: .center)
                    .background(Color(light: .ui.gray98, dark: .systemFill)).clipShape(Circle())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits([.isHeader, .isButton])
        .accessibilityLabel("\(title), \(label)")
        .accessibilityAction(.default, action)
        .padding([.top, .horizontal], ZeroQueryUX.Padding)
    }
}

struct ZeroQueryView: View {
    @ObservedObject var viewModel: ZeroQueryModel

    @Default(.expandSuggestedSites) private var expandSuggestedSites
    @Default(.expandSearches) private var expandSearches
    @Default(.expandSpaces) private var expandSpaces

    var body: some View {
        GeometryReader { geom in
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isPrivate {
                        IncognitoDescriptionView().clipShape(RoundedRectangle(cornerRadius: 12.0)).padding(ZeroQueryUX.Padding)
                    } else {
                        if let promoCardType = viewModel.promoCard {
                            PromoCard(type: promoCardType, viewWidth: geom.size.width)
                        }

                        ZeroQueryHeader(
                            title: "Suggested sites",
                            action: { expandSuggestedSites.advance() },
                            label: "\(expandSuggestedSites.verb) this section",
                            icon: expandSuggestedSites.icon
                        )
                        if expandSuggestedSites != .hidden {
                            SuggestedSitesView(isExpanded: expandSuggestedSites == .expanded)
                        }

                        ZeroQueryHeader(
                            title: "Searches",
                            action: { expandSearches.toggle() },
                            label: "\(expandSearches ? "hides" : "shows") this section",
                            icon: expandSearches ? .chevronUp : .chevronDown
                        )
                        if expandSearches {
                            SuggestedSearchesView()
                        }

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

                    Spacer()
                }
            }.environment(\.viewWidth, geom.size.width)
        }
    }
}

#if DEV
struct ZeroQueryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZeroQueryView(viewModel: ZeroQueryModel())
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
