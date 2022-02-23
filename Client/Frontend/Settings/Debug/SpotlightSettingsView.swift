// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

struct SpotlightSettingsView: View {
    @Default(.createUserActivities) var createUserActivities
    @Default(.makeActivityAvailForSearch) var makeActivityAvailForSearch

    @State private var deletingActivities = false

    var body: some View {
        List {
            Section(header: Text(verbatim: "Browsing User Activity")) {
                Toggle(String("Create User Activities"), isOn: $createUserActivities)
                Toggle(String("Add User Activities to Spotlight"), isOn: $makeActivityAvailForSearch)
                Button(action: {
                    deletingActivities = true
                    NSUserActivity.deleteAllSavedUserActivities {
                        deletingActivities = false
                    }
                }, label: {
                    HStack {
                        Text("Delete all user activities")
                            .foregroundColor(.red)
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .opacity(deletingActivities ? 1 : 0)
                    }
                })
            }

        }
        .font(.system(.footnote, design: .monospaced))
        .minimumScaleFactor(0.75)
        .listStyle(.insetGrouped)
        .applyToggleStyle()
    }
}
