// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

enum TabLocationViewUX {
    static let height: CGFloat = 42
}

struct TabLocationButtonStyle: ButtonStyle {
    struct Body: View {
        let configuration: Configuration

        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            configuration.label
                .brightness(configuration.isPressed ? (
                    colorScheme == .dark ? 0.2 : -0.3
                ) : 0)
        }
    }
    func makeBody(configuration: Configuration) -> Body {
        Body(configuration: configuration)
    }
}

struct TabLocationView: View {
    @Binding var text: String?
    let isPrivate: Bool
    let isLoading: Bool
    @Binding var url: URL

    @ViewBuilder
    var displayedText: some View {
        let showQueryInLocationBar = NeevaFeatureFlags[.clientHideSearchBox]
        if let internalURL = InternalURL(url), internalURL.isAboutHomeURL {
            Text("Search or enter address").foregroundColor(.secondary)
        } else if showQueryInLocationBar, let query = neevaSearchEngine.queryForSearchURL(url), !NeevaConstants.isNeevaPageWithSearchBox(url: url) {
            Label { Text(query) } icon: { Symbol(.magnifyingglass) }
        } else if let scheme = url.scheme, let host = url.host, (scheme == "https" || scheme == "http") {
            // NOTE: Punycode support was removed
            let host = Text(host).truncationMode(.head)
            if scheme == "https" {
                Label {
                    host
                } icon: {
                    Symbol(.lockFill)
                }
            } else {
                host
            }
        } else {
            Text(url.absoluteString)
        }
    }

    var body: some View {
        Button(action: { text = url.absoluteString }) {
            Capsule()
                .fill(Color.systemFill)
        }
        .buttonStyle(TabLocationButtonStyle())
        .overlay(TabLocationAligner {
            displayedText.frame(height: TabLocationViewUX.height)
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {}

        })
        .frame(height: TabLocationViewUX.height)
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabLocationView(text: .constant(nil), isPrivate: false, isLoading: false, url: .constant(URL(string: "http://vviii.verylong.subdomain.neeva.com")!))
            TabLocationView(text: .constant(nil), isPrivate: true, isLoading: false, url: .constant(URL(string: "https://neeva.com/asdf")!))
            TabLocationView(text: .constant(nil), isPrivate: false, isLoading: true, url: .constant(neevaSearchEngine.searchURLForQuery("a long search query with words")!))
            TabLocationView(text: .constant(nil), isPrivate: true, isLoading: true, url: .constant(URL(string: "ftp://someftpsite.com/dir/file.txt")!))
        }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
