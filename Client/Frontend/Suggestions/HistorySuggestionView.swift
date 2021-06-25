// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage

struct HistorySuggestionView: View {
    let site: Site

    @Environment(\.onOpenURL) private var openURL

    var body: some View {
        let url = site.url.asURL!
        SuggestionRow {
            ClientLogger.shared.logCounter(LogConfig.Interaction.HistorySuggestion)
            openURL(url)
        } icon: {
            FaviconView(url: url, icon: site.icon,
                        size: SearchViewControllerUX.IconSize,
                        bordered: true)
                .frame(
                    width: SearchViewControllerUX.ImageSize,
                    height: SearchViewControllerUX.ImageSize
                )
                .cornerRadius(4)
        } label: {
            if let title = site.title, !title.isEmpty {
                Text(title).foregroundColor(.primary).font(.caption).lineLimit(1)
            }
        } secondaryLabel: {
            Text(URL(string: site.url)?.normalizedHostAndPathForDisplay ?? site.url)
                .foregroundColor(.secondaryLabel).font(.caption).lineLimit(1)
        } detail: {
            EmptyView()
        }
    }
}

struct HistorySuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HistorySuggestionView(site: Site(url: "https://neeva.com", title: "Neeva"))
            HistorySuggestionView(site: Site(url: "https://neeva.com", title: ""))
            HistorySuggestionView(site: Site(url: "https://google.com", title: "Google"))
        }
        .previewLayout(.fixed(width: 375, height: 200))
    }
}
