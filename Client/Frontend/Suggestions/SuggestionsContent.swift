/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Apollo
import Defaults
import Shared
import Storage
import SwiftUI
import UIKit

struct SuggestionsContent: View {
    @ObservedObject var suggestionModel: SuggestionModel

    var body: some View {
        GeometryReader { outerGeometry in
            /// This is a hack to cause SwiftUI to call this function again when `outerGeometry` changes due to device rotation.
            /// By reading that value, SwiftUI thinks our computation depends on it.
            /// See https://github.com/neevaco/neeva-ios-phoenix/pull/210 for a detailed explanation.
            let _ = outerGeometry.size.height

            VStack(spacing: 0) {
                if let error = suggestionModel.error {
                    GeometryReader { geom in
                        ScrollView {
                            ErrorView(error, in: self, tryAgain: suggestionModel.reload)
                                .frame(minHeight: geom.size.height)
                        }
                    }
                } else {
                    SuggestionsList()
                        .environmentObject(suggestionModel)
                }
                Spacer()
                    .frame(height: suggestionModel.getKeyboardHeight())
            }
            .ignoresSafeArea(edges: [.bottom])
        }.onAppear {
            suggestionModel.reload()
        }
    }
}
