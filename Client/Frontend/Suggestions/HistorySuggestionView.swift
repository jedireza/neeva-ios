// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage

struct HistorySuggestionView: View {
    let site: Site

    @Environment(\.onOpenURL) private var openURL

    @ViewBuilder private func content(_ url: URL) -> some View {
        Button(action: { openURL(url) }) {
            HStack {
                FaviconView(site: site, size: SearchViewControllerUX.IconSize, bordered: true)
                    .frame(
                        width: SearchViewControllerUX.ImageSize,
                        height: SearchViewControllerUX.ImageSize
                    )
                    .cornerRadius(4)
                VStack(alignment: .leading) {
                    if site.title.isEmpty {
                        Text(site.url)
                    } else {
                        Text(site.title)
                        Text(site.url).foregroundColor(.secondaryLabel)
                    }
                }.font(.caption).lineLimit(1)
            }
        }
    }

    var body: some View {
        if let url = URL(string: site.url) {
            content(url)
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
