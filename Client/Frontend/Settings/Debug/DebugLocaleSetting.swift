// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct DebugLocaleSetting: View {
    @ObservedObject var userInfo = NeevaUserInfo.shared

    var body: some View {
        Picker(String("Country"), selection: $userInfo.countryCode) {
            ForEach(Array(SearchEngine.countryMapping).sorted(by: { $0.0 < $1.0 }), id: \.key) {
                (key, value) in
                HStack {
                    Text(key)
                    if key != value {
                        Text(verbatim: "(\(value))")
                            .foregroundColor(.secondary)
                    }
                }.tag(key)
            }
        }
    }
}

struct DebugLocaleSetting_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            DebugLocaleSetting()
        }
    }
}
