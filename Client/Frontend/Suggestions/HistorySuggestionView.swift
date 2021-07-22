// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage

struct HistorySuggestionView: View {
    let site: Site

    @State var focused = false
    @Environment(\.onOpenURL) private var openURL

    @ViewBuilder
    var icon: some View {
        FaviconView(url: site.url.asURL!, icon: site.icon,
                    size: SearchViewControllerUX.FaviconSize,
                    bordered: false)
            .frame(
                width: SearchViewControllerUX.IconSize,
                height: SearchViewControllerUX.IconSize
            )
            .cornerRadius(4)
            .overlay(RoundedRectangle(cornerRadius: SuggestionViewUX.CornerRadius)
                        .stroke(Color.quaternarySystemFill, lineWidth: 1))
    }

    @ViewBuilder
    var label: some View {
        let title = site.title
        if !title.isEmpty {
            Text(title).withFont(.bodyLarge).foregroundColor(.primary).lineLimit(1)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        Text(URL(string: site.url)?.normalizedHostAndPathForDisplay ?? site.url)
            .withFont(.bodySmall)
            .foregroundColor(.secondaryLabel).lineLimit(1)
    }

    var body: some View {
        SuggestionView(action: {
                ClientLogger.shared.logCounter(LogConfig.Interaction.HistorySuggestion)
                openURL(site.url.asURL!)
            }, icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: EmptyView(),
            suggestion: nil)
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
