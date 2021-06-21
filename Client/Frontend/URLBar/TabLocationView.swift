// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

enum TabLocationViewUX {
    static let height: CGFloat = 42
    static let placeholder = Text("Search or enter address")
}

// note: explicitly ignores the disabled state
fileprivate struct TabLocationButtonStyle: ButtonStyle {
    struct Body: View {
        let configuration: Configuration

        @Environment(\.isIncognito) private var isIncognito

        var body: some View {
            configuration.label
                .foregroundColor(
                    isIncognito
                        ? configuration.isPressed ? .neeva.DarkElevated : .black
                        : configuration.isPressed ? .tertiarySystemFill : .systemFill
                )
        }
    }
    func makeBody(configuration: Configuration) -> Body {
        Body(configuration: configuration)
    }
}

struct TabLocationView: View {
    @ObservedObject var model: URLBarModel
    let onReload: () -> ()
    let onSubmit: (String) -> ()
    let onShare: (UIView) -> ()

    // TODO: when removing support for iOS 14, change this to a Bool to manage focus
    @State private var textField: UITextField?

    @Environment(\.isIncognito) private var isIncognito
    @Environment(\.colorScheme) private var colorScheme

    @ViewBuilder var contextMenu: some View {
        Button(action: {
            UIPasteboard.general.url = model.url
        }) {
            Label("Copy", systemSymbol: .docOnDoc)
        }
        Button(action: {
            UIPasteboard.general.asyncString()
                .uponQueue(.main) { model.text = $0.successValue as? String }
        }) {
            Label("Paste", systemSymbol: .docOnClipboard)
        }
        Button(action: {
            UIPasteboard.general.asyncString()
                .uponQueue(.main) { ($0.successValue as? String).map(onSubmit) }
        }) {
            Label("Paste & Go", systemSymbol: .docOnClipboardFill)
        }
    }

    var body: some View {
        let isEditing = model.text != nil
        HStack {
            Button(action: {
                if let query = neevaSearchEngine.queryForLocationBar(from: model.url) {
                    model.text = query
                } else {
                    // TODO: Decode punycode hostname.
                    model.text = model.url?.absoluteString ?? ""
                }
            }) {
                Capsule()
            }
            .disabled(isEditing)
            .buttonStyle(TabLocationButtonStyle())
            .overlay(TabLocationAligner(transitionToEditing: isEditing) {
                LocationLabel(url: model.url, isSecure: model.isSecure)
                    .lineLimit(1)
                    .frame(height: TabLocationViewUX.height)
                    .allowsHitTesting(false)
            } leading: {
                LocationViewTrackingButton()
            } trailing: {
                Group {
                    if model.readerMode != .active {
                        LocationViewReloadButton(state: $model.reloadButton, onTap: onReload)
                    }
                    LocationViewShareButton(url: model.url, canShare: model.canShare, onTap: onShare)
                }.transition(.move(edge: .trailing).combined(with: .opacity))
            }.opacity(isEditing ? 0 : 1))
            .contextMenu {
                if model.text == nil {
                    contextMenu
                }
            }
            .overlay(Group {
                if isEditing {
                    LocationTextField(text: $model.text, onSubmit: onSubmit, textField: $textField)
                }
            })
            .frame(height: TabLocationViewUX.height)
            .colorScheme(isIncognito ? .dark : colorScheme)
            if isEditing {
                Button {
                    model.text = nil
                    textField?.resignFirstResponder()
                } label: {
                    Text("Cancel").fontWeight(.medium)
                }.transition(.move(edge: .trailing))
            }
        }.animation(.spring(response: 0.3))
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabLocationView(model: URLBarModel(url: "http://vviii.verylong.subdomain.neeva.com"), onReload: {}, onSubmit: { _ in }, onShare: { _ in })
            TabLocationView(model: URLBarModel(url: "https://neeva.com/asdf"), onReload: {}, onSubmit: { _ in }, onShare: { _ in }).environment(\.isIncognito, true)
            TabLocationView(model: URLBarModel(url: neevaSearchEngine.searchURLForQuery("a long search query with words")), onReload: {}, onSubmit: { _ in }, onShare: { _ in })
            TabLocationView(model: URLBarModel(url: "ftp://someftpsite.com/dir/file.txt"), onReload: {}, onSubmit: { _ in }, onShare: { _ in }).environment(\.isIncognito, true)
        }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
