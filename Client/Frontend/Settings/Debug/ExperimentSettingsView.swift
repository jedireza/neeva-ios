// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct ExperimentSettingsView: View {
    @Environment(\.dismissScreen) var dismissScreen

    let scrollViewAppearance = UINavigationBar.appearance().scrollEdgeAppearance

    var body: some View {
        List {
            Group {
                Button {
                    NeevaExperiment.resetAllExperiments()
                } label: {
                    Text("Reset all experiments")
                        .foregroundColor(Color.label)
                }

                Button {
                    NeevaExperiment.forceExperimentArm(
                        experiment: .defaultBrowserPrompt,
                        experimentArm: .showDBPrompt
                    )
                } label: {
                    Text("Force Default Browser Prompt Experiment")
                        .foregroundColor(Color.label)
                }
            }
        }
        .listStyle(.insetGrouped)
        .applyToggleStyle()
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExperimentSettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            ExperimentSettingsView()
        }
    }
}
