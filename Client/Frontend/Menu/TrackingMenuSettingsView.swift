// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct TrackingMenuSettingsView: View {
    let host: String
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("On \(host)").padding(.top, 21)) {
                    TrackingSettingsBlock(
                        blockTrackingCookies: .constant(true),
                        blockTrackingRequests: .constant(true),
                        upgradeToHTTPS: .constant(true)
                    )
                }
                Section(header: Text("Global Privacy Settings")) {
                    TrackingSettingsBlock(
                        blockTrackingCookies: .constant(true),
                        blockTrackingRequests: .constant(true),
                        upgradeToHTTPS: .constant(true)
                    )
                }
                TrackingAttribution()
            }
            .navigationTitle("Advanced Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {}) {
                        Text("Done").bold()
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .applyToggleStyle()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TrackingAttribution: View {
    @Environment(\.onOpenURL) var openURL
    var body: some View {
        EmptyView()
        // TODO: re-enable this with correct attribution
//        Section(header: Group {
//            Button(action: { openURL(URL(string: "https://easylist.to/pages/about.html")!) }) {
//                Label {
//                    Text("Tracking rules courtesy The EasyList Authors")
//                } icon: {
//                    Symbol(.ccBy, size: 13, relativeTo: .footnote)
//                }
//            }
//            .font(.footnote)
//            .accentColor(.secondaryLabel)
//            .textCase(nil)
//        }) {}
    }
}

struct TrackingSettingsBlock: View {
    @Binding var blockTrackingCookies: Bool
    @Binding var blockTrackingRequests: Bool
    @Binding var upgradeToHTTPS: Bool

    var body: some View {
        Toggle("Block tracking cookies", isOn: $blockTrackingCookies)
        Toggle("Block tracking requests", isOn: $blockTrackingRequests)
        Toggle("Update requests to HTTPS", isOn: $upgradeToHTTPS)
    }
}

struct TrackingMenuSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuSettingsView(host: "cnn.com")
    }
}
