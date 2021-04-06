//
//  HomeTopSitesView.swift
//  Client
//
//  Created by Bertoldo on 01/04/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Storage

class NeevaHomeTopSitesViewModel : ObservableObject {

    var profile: Profile?

    @Published var topSites: [Site] = [Site]()

    init(profile: Profile) {
        self.profile = profile
    }

    func reload() {
        guard let profile = profile else {
            return
        }

        TopSitesHandler.getTopSites(profile: profile).uponQueue(.main) { sites in
            self.topSites = sites
            print("TopSites: \(self.topSites)")

            for (i, ts) in self.topSites.enumerated() {
                print("TopSite[\(i)]: title:'\(ts.title)' \t- url:'\(ts.tileURL)' \t- description:'\(String(describing: ts.metadata?.description))' ")
            }

            // Refresh the AS data in the background so we'll have fresh data next time we show.
            self.profile?.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: false)
        }
    }
}

struct HomeTopSitesView: View {

    private var sectionTitle: String = "TOP SITES"
    private let iconSize: CGFloat = 40.0
    private let topSiteWidth: CGFloat = 80.0

    @ObservedObject var viewModel: NeevaHomeTopSitesViewModel

    init(profile: Profile) {
        self.viewModel = NeevaHomeTopSitesViewModel(profile: profile)

        /// TODO (@bertoldo): try to replace ScrollView with another kind View. This line bellow will disable the Bounce for all ScrollViews on the App
        UIScrollView.appearance().bounces = false
    }

    func getTopSiteName(topSite: Site) -> String {
        if let provider = topSite.metadata?.providerName {
            print("TopSite Provider: \(provider.lowercased())")
            return provider.lowercased()
        }

        print("TopSite URL Short Display: \(topSite.tileURL.shortDisplayString)")
        return topSite.tileURL.shortDisplayString
    }

    var body: some View {
        Collapsible(title: sectionTitle) {
                ZStack {
                    /// TODO (@bertoldo): for some reason the scrollview is not updating the items.
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.topSites) { topSite in
                                VStack(alignment: .center) {
                                    /// TODO (@bertoldo): transform a Favicon into Image, look at method setFaviconOrDefaultIcon on
                                    /// UIImageViewExtensions.swift
                                    Image(systemName: "rectangle.grid.2x2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: iconSize, height: iconSize, alignment: .top)
                                    Text(getTopSiteName(topSite: topSite))
                                        .font(.topSitesNameFont)
                                        .fontWeight(.light)
                                        .lineLimit(1)
                                        .foregroundColor(.topSitesNameColor)
                                        .background(Color.clear)
                                }
                                .frame(width: topSiteWidth)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    /// TODO (@bertoldo): remove this print debug
                                    print("TopSite[\(String(describing: topSite.id))]: \(topSite.url)")
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .animation(.interactiveSpring())
                }
                .fixedSize(horizontal: false, vertical: false)
                .onAppear() {
                    viewModel.reload()
                }
        }
        .frame(maxWidth: .infinity)
    }
}

struct HomeTopSitesView_Previews: PreviewProvider {
    static var previews: some View {

        let profile: Profile = BrowserProfile(localName: "preview_profile")
        HomeTopSitesView(profile: profile)
    }
}
