// Copyright Neeva. All rights reserved.
import SwiftUI
import Shared
import Storage

/// Renders a nav suggestion
struct NavSuggestionView: View {
    let suggestion: NavSuggestion

    @EnvironmentObject public var model: NeevaSuggestionModel

    @ViewBuilder
    var icon: some View {
        FaviconView(url: suggestion.url,
                    size: SearchViewControllerUX.FaviconSize,
                    bordered: false)
            .frame(
                width: SearchViewControllerUX.IconSize,
                height: SearchViewControllerUX.IconSize
            )
            .cornerRadius(SuggestionViewUX.CornerRadius)
            .overlay(RoundedRectangle(cornerRadius: SuggestionViewUX.CornerRadius)
                        .stroke(Color.quaternarySystemFill, lineWidth: 1))
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
            Text(suggestion.url.normalizedHostAndPathForDisplay)
                .withFont(.bodySmall).foregroundColor(.secondaryLabel).lineLimit(1)
        }
    }

    @ViewBuilder
    var detail: some View {
        EmptyView()
    }

    var body: some View {
        SuggestionView(action: nil,
            icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: EmptyView(),
            suggestion: Suggestion.navigation(suggestion))
            .environmentObject(model)
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
