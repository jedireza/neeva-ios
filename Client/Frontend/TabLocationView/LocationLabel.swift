// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct LocationLabel: View {
    let url: URL?
    let isSecure: Bool
    let securityLevel: URLBarModel.SecurityLevel?

    @EnvironmentObject private var gridModel: GridModel

    var body: some View {
        LocationLabelAndIcon(
            url: url, isSecure: isSecure,
            forcePlaceholder: !gridModel.isHidden
                || (NeevaConstants.isNeevaHome(url: url) && NeevaUserInfo.shared.hasLoginCookie()),
            securityLevel: securityLevel
        )
        .lineLimit(1)
        .frame(height: TabLocationViewUX.height)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Address Bar")
        .accessibilityValue((isSecure ? "Secure connection, " : "") + (url?.absoluteString ?? ""))
        .accessibilityAddTraits(.isButton)
    }
}

/// This view is also used for drag&drop previews and so should not depend on the environment
struct LocationLabelAndIcon: View {
    let url: URL?
    let isSecure: Bool
    let forcePlaceholder: Bool
    let securityLevel: URLBarModel.SecurityLevel?

    var body: some View {
        let placeholder = TabLocationViewUX.placeholder.withFont(.bodyLarge).foregroundColor(
            .secondaryLabel)
        if forcePlaceholder {
            placeholder
        } else if let url = url, let internalURL = InternalURL(url), internalURL.isZeroQueryURL {
            placeholder
        } else if let query = neevaSearchEngine.queryForLocationBar(from: url) {
            Label {
                Text(query).withFont(.bodyLarge)
            } icon: {
                Symbol(.magnifyingglass)
            }
        } else if let scheme = url?.scheme, let host = url?.host,
            scheme == "https" || scheme == "http"
        {
            // NOTE: Punycode support was removed
            let host = Text(host).withFont(.bodyLarge).truncationMode(.head)
            Label {
                host
            } icon: {
                if let tabSecurityLevel = securityLevel {
                    if tabSecurityLevel == URLBarModel.SecurityLevel.none {  //TODO: could merge none with nil

                    } else if tabSecurityLevel == URLBarModel.SecurityLevel.secure {
                        Symbol(.lockFill)
                    } else if tabSecurityLevel == URLBarModel.SecurityLevel.skippableError {
                        Symbol(.exclamationmarkTriangleFill)
                    } else {
                        Symbol(.lockSlashFill)
                    }
                }
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
            LocationLabel(url: nil, isSecure: false, securityLevel: nil)
                .previewDisplayName("Placeholder")

            LocationLabel(
                url: "https://vviii.verylong.subdomain.neeva.com", isSecure: false,
                securityLevel: nil
            )
            .previewDisplayName("Insecure URL")

            LocationLabel(
                url: "https://neeva.com/asdf", isSecure: true,
                securityLevel: URLBarModel.SecurityLevel.secure
            )
            .previewDisplayName("Secure URL")

            LocationLabel(
                url: neevaSearchEngine.searchURLForQuery("a long search query with words"),
                isSecure: true,
                securityLevel: URLBarModel.SecurityLevel.secure
            )
            .previewDisplayName("Search")

            LocationLabel(
                url: "ftp://someftpsite.com/dir/file.txt", isSecure: false,
                securityLevel: URLBarModel.SecurityLevel.none
            )
            .previewDisplayName("Non-HTTP")
        }.padding(.horizontal).previewLayout(.sizeThatFits)
    }
}
