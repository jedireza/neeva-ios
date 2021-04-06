//
//  NeevaHomeView.swift
//  Client
//
//  Created by Bertoldo on 01/04/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Storage
import NeevaSupport

class NeevaHomeViewModel : ObservableObject {

    var profile: Profile?

    @Published var topSites: [Site] = [Site]()
    @Published var searches: [Search] = [Search]()
    @Published var spaces: [Space] = [Space]()

    init(profile: Profile) {
        self.profile = profile
    }
}

struct NeevaHomeView: View {

    let maxTopSites: Int = 10
    let maxSearches: Int = 10
    let maxSpaces: Int = 10

    @ObservedObject var viewModel: NeevaHomeViewModel

    init(viewModel: NeevaHomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack() {
            HomeTopSitesView(profile: viewModel.profile!)
            HomeSearchesView(searches: viewModel.searches)
            HomeSpacesView(spaces: viewModel.spaces)
            Spacer()
        }
    }
}

struct NeevaHomeView_Previews: PreviewProvider {
    static var previews: some View {
        let profile: Profile = BrowserProfile(localName: "preview_profile")
        NeevaHomeView(viewModel: NeevaHomeViewModel(profile: profile))
    }
}
