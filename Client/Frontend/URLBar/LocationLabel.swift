// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct LocationLabel: View {
    let url: URL?
    let isSecure: Bool

    var body: some View {
        LocationLabelAndIcon(url: url, isSecure: isSecure)
            .lineLimit(1)
            .frame(height: TabLocationViewUX.height)
            .allowsHitTesting(false)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Address Bar")
            .accessibilityValue((isSecure ? "Secure connection, " : "") + (url?.absoluteString ?? ""))
            .accessibilityAddTraits(.isButton)
    }
}

struct LocationLabelAndIcon: View {
    let url: URL?
    let isSecure: Bool
    
    var body: some View {
        if let url = url, let internalURL = InternalURL(url), internalURL.isZeroQueryURL {
            TabLocationViewUX.placeholder.withFont(.bodyLarge).foregroundColor(.secondaryLabel)
        } else if let query = neevaSearchEngine.queryForLocationBar(from: url) {
            Label { Text(query).withFont(.bodyLarge) } icon: { Symbol(.magnifyingglass) }
        } else if let scheme = url?.scheme, let host = url?.host, (scheme == "https" || scheme == "http") {
            // NOTE: Punycode support was removed
            let host = Text(host).withFont(.bodyLarge).truncationMode(.head)
            if isSecure {
                Label {
                    host
                } icon: {
                    Symbol(.lockFill)
                }
            } else {
                host
            }
        } else if let url = url {
            Text(url.absoluteString).withFont(.bodyLarge)
        } else {
            TabLocationViewUX.placeholder.withFont(.bodyLarge).foregroundColor(.secondaryLabel)
        }
    }
}

struct LocationLabel_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LocationLabel(url: nil, isSecure: false)
                .previewDisplayName("Placeholder")

            LocationLabel(url: "https://vviii.verylong.subdomain.neeva.com", isSecure: false)
                .previewDisplayName("Insecure URL")

            LocationLabel(url: "https://neeva.com/asdf", isSecure: true)
                .previewDisplayName("Secure URL")

            LocationLabel(url: neevaSearchEngine.searchURLForQuery("a long search query with words"), isSecure: true)
                .previewDisplayName("Search")

            LocationLabel(url: "ftp://someftpsite.com/dir/file.txt", isSecure: false)
                .previewDisplayName("Non-HTTP")
        }.padding(.horizontal).previewLayout(.sizeThatFits)
    }
}
