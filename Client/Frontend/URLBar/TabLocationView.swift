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
    @ObservedObject var model: URLBarModel

    var body: some View {
        Button(action: { text = model.url?.absoluteString ?? "" }) {
            Capsule()
                .fill(Color.systemFill)
        }
        .buttonStyle(TabLocationButtonStyle())
        .overlay(TabLocationAligner {
            LocationLabel(url: model.url, isSecure: model.isSecure)
                .lineLimit(1)
                .frame(height: TabLocationViewUX.height)
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            if model.readerMode != .active {
                LocationViewReloadButton(state: $model.reloadButton)
            }
            TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {}
        })
        .frame(height: TabLocationViewUX.height)
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabLocationView(text: .constant(nil), isPrivate: false, isLoading: false, model: URLBarModel(url: "http://vviii.verylong.subdomain.neeva.com"))
            TabLocationView(text: .constant(nil), isPrivate: true, isLoading: false, model: URLBarModel(url: "https://neeva.com/asdf"))
            TabLocationView(text: .constant(nil), isPrivate: false, isLoading: true, model: URLBarModel(url: neevaSearchEngine.searchURLForQuery("a long search query with words")))
            TabLocationView(text: .constant(nil), isPrivate: true, isLoading: true, model: URLBarModel(url: "ftp://someftpsite.com/dir/file.txt"))
        }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
