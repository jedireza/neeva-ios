// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct NeevaUserFlagSettingsView: View {
    @ObservedObject var userFlagStore = UserFlagStore.shared

    var body: some View {
        List {
            ForEach(UserFlagStore.UserFlag.allCases, id: \.rawValue) { flag in
                HStack {
                    Text(flag.rawValue)
                        .font(.system(.body, design: .monospaced))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Text(
                        userFlagStore.userFlags.contains(
                            flag) ? "true" : "false")
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct NeevaUserFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NeevaUserFlagSettingsView()
                .navigationTitle("Server User Flags")
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
