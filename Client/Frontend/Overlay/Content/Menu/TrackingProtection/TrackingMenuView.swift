// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import SwiftUI

private enum TrackingMenuUX {
    static let hallOfShameElementSpacing: CGFloat = 8
    static let hallOfShameRowSpacing: CGFloat = 60
    static let hallOfShameElementFaviconSize: CGFloat = 25
}

struct TrackingMenuFirstRowElement: View {
    let label: LocalizedStringKey
    let num: Int

    var body: some View {
        GroupedCell(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(label).withFont(.headingMedium).foregroundColor(.secondaryLabel)
                Text("\(num)").withFont(.displayMedium)
            }
            .padding(.bottom, 4)
            .padding(.vertical, 10)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("\(num) \(Text(label)) blocked"))
            .accessibilityIdentifier("TrackingMenu.TrackingMenuFirstRowElement")
        }
    }
}

struct HallOfShameElement: View {
    let hallOfShameDomain: HallOfShameDomain

    var body: some View {
        HStack(spacing: TrackingMenuUX.hallOfShameElementSpacing) {
            Image(hallOfShameDomain.domain.rawValue).resizable().cornerRadius(5)
                .frame(
                    width: TrackingMenuUX.hallOfShameElementFaviconSize,
                    height: TrackingMenuUX.hallOfShameElementFaviconSize)
            Text("\(hallOfShameDomain.count)").withFont(.displayMedium)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(hallOfShameDomain.count) trackers blocked from \(hallOfShameDomain.domain.rawValue)"
        )
        .accessibilityIdentifier("TrackingMenu.HallOfShameElement")
    }
}

struct HallOfShameView: View {
    let hallOfShameDomains: [HallOfShameDomain]

    var body: some View {
        GroupedCell(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Hall of Shame").withFont(.headingMedium).foregroundColor(.secondaryLabel)
                HStack(spacing: TrackingMenuUX.hallOfShameRowSpacing) {
                    ForEach(hallOfShameDomains, id: \.domain.rawValue) { hallOfShameDomain in
                        HallOfShameElement(hallOfShameDomain: hallOfShameDomain)
                    }
                }.padding(.bottom, 4)
            }.padding(.vertical, 14)
        }
    }
}

struct TrackingMenuView: View {
    @EnvironmentObject var viewModel: TrackingMenuModel

    @State private var isShowingPopup = false

    var body: some View {
        GroupedStack {
            if viewModel.preventTrackersForCurrentPage {
                HStack(spacing: 8) {
                    TrackingMenuFirstRowElement(label: "Trackers", num: viewModel.numTrackers)
                    TrackingMenuFirstRowElement(label: "Domains", num: viewModel.numDomains)
                }
                if !viewModel.hallOfShameDomains.isEmpty {
                    HallOfShameView(hallOfShameDomains: viewModel.hallOfShameDomains)
                }
            }

            TrackingMenuProtectionRow()

            if FeatureFlag[.newTrackingProtectionSettings] {
                GroupedCellButton(action: { isShowingPopup = true }) {
                    HStack {
                        Text("Advanced Privacy Settings").withFont(.bodyLarge)
                        Spacer()
                        Symbol(decorative: .shieldLefthalfFill)
                    }.foregroundColor(.label)
                }
                .sheet(isPresented: $isShowingPopup) {
                    TrackingMenuSettingsView(domain: "example.com")
                }
            }
        }
        .fixedSize(horizontal: true, vertical: true)
        .onAppear {
            viewModel.viewVisible = true
            self.viewModel.refreshStats()
        }
        .onDisappear {
            viewModel.viewVisible = false
        }
        .padding(.top, 6)
    }
}
