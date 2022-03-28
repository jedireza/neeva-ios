// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

public struct TrackingMenuProtectionRow: View {
    @EnvironmentObject var trackingStatsViewModel: TrackingMenuModel

    var preventTrackers: Bool {
        trackingStatsViewModel.preventTrackersForCurrentPage
    }

    var titleText: some View {
        Text("Tracking Prevention")
            .withFont(.bodyLarge)
    }

    var callToActionText: some View {
        Text(
            preventTrackers
                ? "Site appears broken? Try disabling."
                : "You've disabled tracking protection\non this site."
        )
        .foregroundColor(.secondaryLabel)
        .font(.footnote)
    }

    public var body: some View {
        GroupedCell {
            if FeatureFlag[.siteSpecificSettings] {
                VStack(alignment: .leading) {
                    titleText
                    callToActionText

                    Button {
                        trackingStatsViewModel.preventTrackersForCurrentPage.toggle()
                    } label: {
                        HStack {
                            Spacer()

                            HStack {
                                Symbol(
                                    decorative: preventTrackers ? .shieldSlash : .checkmarkShield)
                                Text(preventTrackers ? "Turn off for this site" : "Turn back on")
                            }.padding(.horizontal, 28)

                            Spacer()
                        }
                    }
                    .buttonStyle(.neeva(preventTrackers ? .secondary : .primary, height: 42))
                }.padding(.vertical, 12)
            } else {
                Toggle(isOn: $trackingStatsViewModel.preventTrackersForCurrentPage) {
                    VStack(alignment: .leading) {
                        titleText
                        callToActionText
                    }.padding(.trailing)
                }
                .padding(.vertical, 12)
                .applyToggleStyle()
            }
        }
        .accessibilityIdentifier("TrackingMenu.TrackingMenuProtectionRow")
    }
}

struct TrackingMenuProtectionRowButton_Previews: PreviewProvider {
    static var previews: some View {
        let menuModel = TrackingMenuModel(
            testingData: TrackingEntity.getTrackingDataForCurrentTab(stats: TPPageStats()))

        TrackingMenuProtectionRow()
            .environmentObject(menuModel)

        TrackingMenuProtectionRow()
            .environmentObject(menuModel)
    }
}
