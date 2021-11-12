// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

/// Displayed when not editing the URL.
struct LocationLabel: View {
    let url: URL?
    let isSecure: Bool?

    @EnvironmentObject private var gridModel: GridModel

    var body: some View {
        LocationLabelAndIcon(
            url: url, isSecure: isSecure,
            forcePlaceholder: !gridModel.isHidden
                || (NeevaConstants.isNeevaHome(url: url) && NeevaUserInfo.shared.hasLoginCookie())
        )
        .lineLimit(1)
        .frame(height: TabLocationViewUX.height)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Address Bar")
        .accessibilityValue(
            (isSecure ?? false ? "Secure connection, " : "") + (url?.absoluteString ?? "")
        )
        .accessibilityAddTraits(.isButton)
    }
}

/// This view is also used for drag&drop previews and so should not depend on the environment
struct LocationLabelAndIcon: View {
    let url: URL?
    let isSecure: Bool?
    let forcePlaceholder: Bool

    var body: some View {
        let placeholder = TabLocationViewUX.placeholder.withFont(.bodyLarge).foregroundColor(
            .secondaryLabel)
        if forcePlaceholder {
            placeholder
        } else if let query = neevaSearchEngine.queryForLocationBar(from: url) {
            Label {
                Text(query).withFont(.bodyLarge)
            } icon: {
                Symbol(decorative: .magnifyingglass, size: 14)
            }
        } else if let scheme = url?.scheme, let host = url?.host,
            scheme == "https" || scheme == "http"
        {
            // NOTE: Punycode support was removed
            let host = Text(host).withFont(.bodyLarge).truncationMode(.head)
            if url?.scheme == "https" {
                Label {
                    host
                } icon: {
                    if let isSecure = isSecure {
                        if isSecure {
                            Symbol(decorative: .lockFill)
                        } else {
                            Symbol(decorative: .lockSlashFill)
                        }
                    }
                }
            } else {
                host
            }
        } else if let url = url {
            Text(url.absoluteString).withFont(.bodyLarge)
        } else {
            placeholder
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

            LocationLabel(
                url: neevaSearchEngine.searchURLForQuery("a long search query with words"),
                isSecure: true
            )
            .previewDisplayName("Search")

            LocationLabel(url: "ftp://someftpsite.com/dir/file.txt", isSecure: false)
                .previewDisplayName("Non-HTTP")
        }.padding(.horizontal).previewLayout(.sizeThatFits)
    }
}
