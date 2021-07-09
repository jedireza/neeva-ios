// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage

struct HistorySuggestionView: View {
    let site: Site

    @Environment(\.onOpenURL) private var openURL

    var body: some View {
        let url = site.url.asURL!
        SuggestionView {
            ClientLogger.shared.logCounter(LogConfig.Interaction.HistorySuggestion)
            openURL(url)
        } icon: {
            FaviconView(url: url, icon: site.icon,
                        size: SearchViewControllerUX.FaviconSize,
                        bordered: false)
                .frame(
                    width: SearchViewControllerUX.IconSize,
                    height: SearchViewControllerUX.IconSize
                )
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: SuggestionViewUX.CornerRadius)
                            .stroke(Color.quaternarySystemFill, lineWidth: 1))
        } label: {
            if let title = site.title, !title.isEmpty {
                Text(title).withFont(.bodyLarge).foregroundColor(.primary).lineLimit(1)
            }
        } secondaryLabel: {
            Text(URL(string: site.url)?.normalizedHostAndPathForDisplay ?? site.url)
                .withFont(.bodySmall)
                .foregroundColor(.secondaryLabel).lineLimit(1)
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
