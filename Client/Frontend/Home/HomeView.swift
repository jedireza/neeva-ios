//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Storage
import Shared

struct NeevaHomeUX {
    static let FaviconSize: CGFloat = 28
    static let SuggestedSiteIconSize: CGFloat = 40
    static let SuggestedSiteIconCornerRadius: CGFloat = 6
    static let NumberOfItemsPerRowForSizeClassIpad = UXSizeClasses(compact: 3, regular: 4, other: 2)
    static let PinIconSize: CGFloat = 12
    static let SuggestedSiteTitleFontSize: CGFloat = 14
    static let SuggestedSiteBlockWidth: CGFloat = 64
    static let SuggestedSiteBlockHeight: CGFloat = 62
    static let ToggleButtonSize: CGFloat = 32
    static let ToggleIconSize: CGFloat = 14

    static func horizontalItemSpacing(isTabletOrLandscape: Bool) -> CGFloat {
        return isTabletOrLandscape ? 32 : 24
    }

    static func singleRowWidth(isTabletOrLandscape: Bool) -> CGFloat {
        let numItems: CGFloat = isTabletOrLandscape ? 8 : 4
        return numItems * SuggestedSiteBlockWidth + (numItems - 1) * horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)
    }
}

class SuggestedSitesViewModel: ObservableObject {
    @Published var sites: [Site]
    @Published var onSuggestedSiteClicked : (URL) -> ()
    @Published var onSuggestedSiteLongPressed : (Site) -> ()

    init(sites: [Site], onSuggestedSiteClicked: @escaping (URL)->(), onSuggestedSiteLongPressed: @escaping (Site)->()) {
        self.sites = sites
        self.onSuggestedSiteClicked = onSuggestedSiteClicked
        self.onSuggestedSiteLongPressed = onSuggestedSiteLongPressed
    }
}

struct SuggestedSiteView: View {
    let site: Site!
    let isPinnedSite: Bool!

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
        VStack(spacing:2) {
            FaviconView(site: site, size: NeevaHomeUX.FaviconSize, bordered: false)
                .frame(width: NeevaHomeUX.SuggestedSiteIconSize, height: NeevaHomeUX.SuggestedSiteIconSize, alignment: .center)
                .background(Color.Neeva.UI.Gray97)
                .clipShape(RoundedRectangle(cornerRadius: NeevaHomeUX.SuggestedSiteIconCornerRadius))
            HStack {
                if isPinnedSite {
                    Image("pin_small").renderingMode(.template).foregroundColor(Color.Neeva.UI.Gray60)
                        .frame(width: NeevaHomeUX.PinIconSize, height: NeevaHomeUX.PinIconSize, alignment: .center)
                }
                Text(title).lineLimit(1)
                    .font(Font(UIFont.systemFont(ofSize: NeevaHomeUX.SuggestedSiteTitleFontSize, weight: UIFont.Weight.regular)))
                    .padding(.top, 4)
            }
        }.frame(width: NeevaHomeUX.SuggestedSiteBlockWidth, height: NeevaHomeUX.SuggestedSiteBlockHeight)
            .accessibilityLabel(title).accessibilityHint(hint)
            .accessibilityIdentifier("Home.SuggestedSite")

    }
}

struct SuggestedSitesView: View {
    @Binding var expansionState: HomeRowExpansionState
    @EnvironmentObject var viewModel: SuggestedSitesViewModel

    var columns:[GridItem] {
        [GridItem(.fixed(NeevaHomeUX.SuggestedSiteBlockWidth),spacing:
                    NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)),
        GridItem(.fixed(NeevaHomeUX.SuggestedSiteBlockWidth),spacing:
                    NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)),
        GridItem(.fixed(NeevaHomeUX.SuggestedSiteBlockWidth),spacing:
                    NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)),
        GridItem(.fixed(NeevaHomeUX.SuggestedSiteBlockWidth))]
    }

    var isTabletOrLandscape:Bool {
        return UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.orientation.isLandscape
    }

    var body: some View {
        if expansionState == .limited {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)) {
                            ForEach(viewModel.sites.indices, id: \.self) { index in
                                let suggestedSite = viewModel.sites[index]
                                SuggestedSiteView(site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite)
                                    .onTapGesture {
                                        viewModel.onSuggestedSiteClicked(suggestedSite.tileURL)
                                    }.onLongPressGesture {
                                        viewModel.onSuggestedSiteLongPressed(suggestedSite)
                                    }
                            }
                        }.padding(.vertical).frame(maxWidth:.infinity)
                        .padding(.leading, (geometry.size.width -
                                NeevaHomeUX.singleRowWidth(isTabletOrLandscape: isTabletOrLandscape)) / 2)
                    }
                    if UIDevice.current.userInterfaceIdiom != .pad {
                        Rectangle().fill(
                            LinearGradient(gradient: Gradient(stops: [
                                .init(color: Color(UIColor.HomePanel.topSitesBackground).opacity(0), location: 0),
                                .init(color: Color(UIColor.HomePanel.topSitesBackground), location: 1)
                            ]), startPoint: .leading, endPoint: .trailing)
                        ).frame(width: 80).frame(maxWidth: .infinity, alignment: .trailing).allowsHitTesting(false)
                    }
                }.fixedSize(horizontal: false, vertical: true)
            }
        } else if expansionState == .all {
            ZStack {
                ScrollView() {
                    LazyVGrid(columns: columns ,spacing:
                                NeevaHomeUX.horizontalItemSpacing(isTabletOrLandscape: isTabletOrLandscape)) {
                        ForEach(viewModel.sites.indices, id: \.self) { index in
                            let suggestedSite = viewModel.sites[index]
                            SuggestedSiteView(site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite).onTapGesture {
                                viewModel.onSuggestedSiteClicked(suggestedSite.tileURL)
                            }.onLongPressGesture {
                                viewModel.onSuggestedSiteLongPressed(suggestedSite)
                            }
                        }
                    }.padding(.vertical)
                }
            }.fixedSize(horizontal: false, vertical: true)
        }
    }
}

enum HomeRowExpansionState: Int {
    case limited, all
}

struct NeevaHomeRow: View {
    @State private var expansionState: HomeRowExpansionState = UserDefaults.standard.bool(forKey: PrefsKeys.KeySetSuggestedSitesToShowAll) ? .all : .limited

    var body: some View {
        VStack {
            HStack {
                Text("Suggested sites").textCase(.uppercase).foregroundColor(Color.Neeva.UI.Gray60)
                    .font(Font.custom("Roobert-SemiBold", size:13)).minimumScaleFactor(0.6)
                    .lineLimit(1).padding(.leading, 4)
                    .accessibilityIdentifier("Home.SuggestedSitesLabel")
                Spacer()
                Button(action: {
                    expansionState = HomeRowExpansionState(rawValue: expansionState.rawValue.advanced(by: 1)) ?? .limited
                    UserDefaults.standard.set(expansionState == HomeRowExpansionState.all, forKey: PrefsKeys.KeySetSuggestedSitesToShowAll)
                }, label: {
                    let icon = expansionState == .limited ? Nicon.chevronDown : Nicon.chevronUp
                    Symbol(icon, size: NeevaHomeUX.ToggleIconSize, label: "Show \(expansionState == .limited ? "more" : "fewer") suggested sites")
                        .frame(width: NeevaHomeUX.ToggleButtonSize, height: NeevaHomeUX.ToggleButtonSize, alignment: .center)
                        .background(Color.Neeva.UI.Gray98).clipShape(Circle())
                }).accessibilityIdentifier("Home.SuggestedSitesToggle")
            }.padding(.bottom)
            SuggestedSitesView(expansionState: $expansionState)
        }.padding()
    }
}

struct NeevaHome: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if viewModel.isPrivate {
                    IncognitoDescriptionView().clipShape(RoundedRectangle(cornerRadius: 12.0)).padding()
                }
                if !viewModel.isPrivate && viewModel.showDefaultBrowserCard {
                    DefaultBrowserCardView(dismissClosure: viewModel.toggleShowCard, signInHandler: viewModel.signInHandler).frame(height: 178)
                }
                NeevaHomeRow()
                Spacer()
            }
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var isPrivate: Bool = false
    @Published var showDefaultBrowserCard = false
    @Published var signInHandler: () -> () = {}
    var toggleShowCard: () -> () {
        return { self.showDefaultBrowserCard.toggle()}
    }
}

struct DefaultBrowserCardView: UIViewRepresentable {
    let dismissClosure: () -> ()
    let signInHandler: () -> ()

    func makeUIView(context: Context) -> DefaultBrowserCard {
        let card = DefaultBrowserCard(frame:.zero, isUserLoggedIn: NeevaUserInfo.shared.isUserLoggedIn)
        card.dismissClosure = dismissClosure
        card.signinHandler = signInHandler
        return card
    }

    func updateUIView(_ defaultBrowserCard: DefaultBrowserCard, context: Context) {
    }
}

struct NeevaHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaHome(viewModel: HomeViewModel()).environmentObject(SuggestedSitesViewModel(sites: [Site](), onSuggestedSiteClicked: {_ in }, onSuggestedSiteLongPressed: { _ in }))
    }
}
