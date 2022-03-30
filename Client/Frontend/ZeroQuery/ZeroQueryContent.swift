// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import SDWebImage
import Shared
import Storage
import SwiftUI
import UIKit
import XCGLogger

extension EnvironmentValues {
    private struct HideTopSiteKey: EnvironmentKey {
        static var defaultValue: ((Site) -> Void)? = nil
    }

    public var zeroQueryHideTopSite: (Site) -> Void {
        get {
            self[HideTopSiteKey.self] ?? { _ in
                fatalError(".environment(\\.zeroQueryHideTopSite) must be specified")
            }
        }
        set { self[HideTopSiteKey.self] = newValue }
    }
}

struct ZeroQueryContent: View {
    @ObservedObject var model: ZeroQueryModel
    @EnvironmentObject var suggestedSearchesModel: SuggestedSearchesModel

    var body: some View {
        ZeroQueryView()
            .backgroundColorOrGradient()
            .environmentObject(model)
            .environment(\.setSearchInput) { query in
                model.delegate?.zeroQueryPanel(didEnterQuery: query)
            }
            .environment(\.onOpenURL) { url in
                model.delegate?.zeroQueryPanel(didSelectURL: url, visitType: .bookmark)
            }
            .environment(\.shareURL, model.shareURLHandler)
            .environment(\.zeroQueryHideTopSite, model.hideURLFromTopSites)
            .environment(\.openInNewTab) { url, isIncognito in
                model.delegate?.zeroQueryPanelDidRequestToOpenInNewTab(
                    url, isIncognito: isIncognito)
            }
            .environment(\.saveToSpace) { url, title, description in
                model.delegate?.zeroQueryPanelDidRequestToSaveToSpace(
                    url,
                    title: title,
                    description: description)
            }
            .onAppear {
                if let date = Defaults[.lastZeroQueryImpUpdatedTimestamp],
                    Calendar.current.isDateInYesterday(date)
                {
                    Defaults[.numOfDailyZeroQueryImpression] = 0
                }
                Defaults[.numOfDailyZeroQueryImpression] += 1
                Defaults[.lastZeroQueryImpUpdatedTimestamp] = Date()

                self.model.updateState()
                self.suggestedSearchesModel.reload(from: self.model.profile)
            }
    }
}
