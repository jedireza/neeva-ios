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
    @Default(.addThumbnailToActivities) var addThumbnailToActivities
    @Default(.addSpacesToCS) var addSpacesToCS

    @State private var deletingActivities = false

    @State private var deletingSpaces = false
    @State private var deletingAllSpaceIndex = false
    var spaceIndexBusy: Bool { deletingSpaces || deletingAllSpaceIndex }

    var body: some View {
        List {
            Section(header: Text(verbatim: "Browsing User Activity")) {
                Toggle(String("Create User Activities"), isOn: $createUserActivities)
                Toggle(String("Add User Activities to Spotlight"), isOn: $makeActivityAvailForSearch)
                Toggle(String("Add Thumbnails to Attributes"), isOn: $addThumbnailToActivities)
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

            Section(header: Text(verbatim: "Spaces")) {
                Toggle(String("Add Spaces Data to Spotlight"), isOn: $addSpacesToCS)
                // Delete Buttons
                Group {
                    Button(action: {
                        deletingSpaces = true
                        SpaceStore.removeAllSpacesFromCoreSpotlight { error in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            deletingSpaces = false
                        }
                    }, label: {
                        HStack {
                        Text("Remove All Spaces from Index")
                            .foregroundColor(.red)
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .opacity(deletingSpaces ? 1 : 0)
                        }
                    })

                    Button(action: {
                        deletingAllSpaceIndex = true
                        SpaceStore.clearIndex { error in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            deletingAllSpaceIndex = false
                        }
                    }, label: {
                        HStack {
                        Text("Clear Space Index")
                            .foregroundColor(.red)
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .opacity(deletingAllSpaceIndex ? 1 : 0)
                        }
                    })
                }
                .disabled(spaceIndexBusy)
            }

        }
        .font(.system(.footnote, design: .monospaced))
        .minimumScaleFactor(0.75)
        .listStyle(.insetGrouped)
        .applyToggleStyle()
    }
}
