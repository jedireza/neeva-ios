// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

struct SearchEngineSettings: View {
    @ObservedObject private var userInfo = NeevaUserInfo.shared

    @Default(.customSearchEngine) var customSearchEngine

    var body: some View {
        List {
            Picker("Recommended", selection: $customSearchEngine) {
                HStack {
                    Image("neeva-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical, -1.5)
                    Image("neeva-letter-only")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 5)
                }
                .frame(height: 20)
                .padding(.vertical, 10)
                .accessibilityLabel("Neeva")
                .tag(nil as String?)
            }

            Picker("Other search engines", selection: $customSearchEngine) {
                ForEach(SearchEngine.all(for: userInfo.countryCode)) { engine in
                    Label {
                        Text(engine.label)
                    } icon: {
                        WebImage(url: engine.icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .cornerRadius(3)
                    }.tag(engine.id as String?)
                }
            }
        }
        .listStyle(.insetGrouped)
        .pickerStyle(.inline)
    }
}

struct SearchEngineSettings_Previews: PreviewProvider {
    static var previews: some View {
        SearchEngineSettings()
        SearchEngineSettings().colorScheme(.dark)
    }
}
