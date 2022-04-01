// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct NonEssentialCookieSettings: View {
    @EnvironmentObject var cookieCutterModel: CookieCutterModel

    var body: some View {
        List {
            Section(
                footer:
                    VStack(alignment: .leading) {
                        Text(
                            "If a site does not support selecting these options individually, then all non-essential cookies for the site will be accepted."
                        )
                    }
            ) {
                Toggle(isOn: $cookieCutterModel.marketingCookiesAllowed) {
                    DetailedSettingsLabel(
                        title: "Marketing Cookies",
                        description: "Tracks your online activity for advertising purposes"
                    ).padding(.vertical, 8)
                }

                Toggle(isOn: $cookieCutterModel.analyticCookiesAllowed) {
                    DetailedSettingsLabel(
                        title: "Analytics Cookies",
                        description: "Collects information about your visits and actions on a site"
                    ).padding(.vertical, 8)
                }

                Toggle(isOn: $cookieCutterModel.socialCookiesAllowed) {
                    DetailedSettingsLabel(
                        title: "Social Cookies",
                        description:
                            "Personalization and social media features from third party providers"
                    ).padding(.vertical, 8)
                }
            }
        }
        .listStyle(.insetGrouped)
        .pickerStyle(.inline)
        .applyToggleStyle()
        .navigationTitle(Text("Non-essential Cookies"))
    }
}

struct NonEssentialCookieSettings_Previews: PreviewProvider {
    static var previews: some View {
        NonEssentialCookieSettings()
            .environmentObject(
                CookieCutterModel(toastViewManager: ToastViewManager(window: UIWindow())))
    }
}
