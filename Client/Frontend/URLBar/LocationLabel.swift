// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct LocationLabel: View {
    @Binding var url: URL?
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
        if let url = url, let internalURL = InternalURL(url), internalURL.isAboutHomeURL {
            TabLocationViewUX.placeholder.foregroundColor(.secondaryLabel)
        } else if let query = neevaSearchEngine.queryForLocationBar(from: url) {
            Label { Text(query) } icon: { Symbol(.magnifyingglass) }
        } else if let scheme = url?.scheme, let host = url?.host, (scheme == "https" || scheme == "http") {
            // NOTE: Punycode support was removed
            let host = Text(host).truncationMode(.head)
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
            Text(url.absoluteString)
        } else {
            TabLocationViewUX.placeholder.foregroundColor(.secondaryLabel)
        }
    }
}

struct LocationLabel_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LocationLabel(url: .constant("http://vviii.verylong.subdomain.neeva.com"), isSecure: false)
            LocationLabel(url: .constant("https://neeva.com/asdf"), isSecure: true)
            LocationLabel(url: .constant(neevaSearchEngine.searchURLForQuery("a long search query with words")), isSecure: false)
            LocationLabel(url: .constant("ftp://someftpsite.com/dir/file.txt"), isSecure: false)
        }.padding().previewLayout(.sizeThatFits)
    }
}
