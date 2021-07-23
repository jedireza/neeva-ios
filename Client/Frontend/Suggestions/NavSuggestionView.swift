// Copyright Neeva. All rights reserved.
import SwiftUI
import Shared
import Storage

/// Renders a nav suggestion
struct NavSuggestionView: View {
    let suggestion: NavSuggestion

    @State var focused = false
    @Environment(\.onOpenURL) private var openURL

    @ViewBuilder
    var icon: some View {
        if let url = URL(string: suggestion.url) {
            FaviconView(url: url,
                        size: SearchViewControllerUX.FaviconSize,
                        bordered: false)
                .frame(
                    width: SearchViewControllerUX.IconSize,
                    height: SearchViewControllerUX.IconSize
                )
                .cornerRadius(SuggestionViewUX.CornerRadius)
                .overlay(RoundedRectangle(cornerRadius: SuggestionViewUX.CornerRadius)
                            .stroke(Color.quaternarySystemFill, lineWidth: 1))
        } else {
            Symbol(.questionmarkDiamondFill)
                .foregroundColor(.red)
        }
    }

    @ViewBuilder
    var label: some View {
        if let title = suggestion.title {
            Text(title).withFont(.bodyLarge).lineLimit(1)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        if let title = suggestion.title {
            Text(URL(string: suggestion.url)?.normalizedHostAndPathForDisplay ?? title)
                .withFont(.bodySmall).foregroundColor(.secondaryLabel).lineLimit(1)
        }
    }

    @ViewBuilder
    var detail: some View {
        EmptyView()
    }

    var body: some View {
        SuggestionView(action: {
                ClientLogger.shared.logCounter(LogConfig.Interaction.HistorySuggestion)
                openURL(suggestion.url.asURL!)
            }, icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: EmptyView(),
            suggestion: nil)
    }
}

struct NavSuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NavSuggestionView(suggestion: NavSuggestion(url: "https://neeva.com", title: "Neeva"))
            NavSuggestionView(suggestion: NavSuggestion(url: "https://neeva.com", title: ""))
            NavSuggestionView(suggestion: NavSuggestion(url: "https://google.com", title: "Google"))
        }
        .previewLayout(.fixed(width: 375, height: 200))
    }
}
