// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared
import Defaults

public struct NeevaHomeUX {
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
                    .background(Color.neeva.ui.fixed.gray98).clipShape(Circle())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits([.isHeader, .isButton])
        .accessibilityLabel("\(title), \(label)")
        .accessibilityAction(.default, action)
        .padding([.top, .horizontal], NeevaHomeUX.Padding)
    }
}

struct NeevaHome: View {
    @ObservedObject var viewModel: HomeViewModel

    @Default(.expandSuggestedSites) private var expandSuggestedSites
    @Default(.expandSearches) private var expandSearches
    @Default(.expandSpaces) private var expandSpaces

    var body: some View {
        GeometryReader { geom in
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isPrivate {
                        IncognitoDescriptionView().clipShape(RoundedRectangle(cornerRadius: 12.0)).padding(NeevaHomeUX.Padding)
                    } else {
                        if viewModel.showDefaultBrowserCard {
                            PromoCard(model: viewModel)
                        }

                        NeevaHomeHeader(
                            title: "Suggested sites",
                            action: { expandSuggestedSites.advance() },
                            label: "\(expandSuggestedSites.verb) this section",
                            icon: expandSuggestedSites.icon
                        )
                        if expandSuggestedSites != .hidden {
                            SuggestedSitesView(isExpanded: expandSuggestedSites == .expanded)
                        }

                        NeevaHomeHeader(
                            title: "Searches",
                            action: { expandSearches.toggle() },
                            label: "\(expandSearches ? "hides" : "shows") this section",
                            icon: expandSearches ? .chevronUp : .chevronDown
                        )
                        if expandSearches {
                            SuggestedSearchesView()
                        }

                        NeevaHomeHeader(
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
