// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct TrackingMenuSettingsView: View {
    @Default(.unblockedDomains) var unblockedDomains: Set<String>

    @State var domainIsNotSafelisted: Bool = false {
        didSet {
            TrackingPreventionConfig.updateAllowList(with: domain, allowed: !domainIsNotSafelisted)
        }
    }

    let domain: String
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("On \(domain)").padding(.top, 21)) {
                    Toggle("Tracking Prevention", isOn: $domainIsNotSafelisted)
                }
                Section(header: Text("Global Privacy Settings")) {
                    TrackingSettingsBlock()
                }
                TrackingAttribution()
            }
            .navigationTitle("Advanced Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {}
                }
            }
            .listStyle(GroupedListStyle())
            .applyToggleStyle()
        }.navigationViewStyle(StackNavigationViewStyle()).onAppear {
            domainIsNotSafelisted = !unblockedDomains.contains(domain)
        }
    }
}

struct TrackingAttribution: View {
    // @Environment(\.onOpenURL) var openURL
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
    @Default(.blockThirdPartyTrackingCookies) var blockTrackingCookies: Bool
    @Default(.blockThirdPartyTrackingRequests) var blockTrackingRequests: Bool
    @Default(.upgradeAllToHttps) var upgradeToHTTPS: Bool

    var body: some View {
        Toggle("Block tracking cookies", isOn: $blockTrackingCookies)
        Toggle("Block tracking requests", isOn: $blockTrackingRequests)
        Toggle("Update requests to HTTPS", isOn: $upgradeToHTTPS)
    }
}

struct TrackingMenuSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuSettingsView(domain: "cnn.com")
    }
}
