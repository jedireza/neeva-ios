// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults
import UniformTypeIdentifiers

enum TabLocationViewUX {
    static let height: CGFloat = 42
    static let placeholder = Text("Search or enter address")
}

struct TabLocationView: View {
    @ObservedObject var model: URLBarModel
    let onReload: () -> ()
    let onSubmit: (String) -> ()
    let onShare: (UIView) -> ()
    let buildReloadMenu: () -> UIMenu?

    // TODO: when removing support for iOS 14, change this to a Bool to manage focus
    @State private var textField: UITextField?

    @State private var isPressed = false
    @ObservedObject private var searchQuery = SearchQueryModel.shared
    @Environment(\.isIncognito) private var isIncognito
    @Environment(\.colorScheme) private var colorScheme

    private var copyAction: Action {
        Action("Copy", icon: .docOnDoc) {
            UIPasteboard.general.url = model.url
        }
    }
    private var pasteAction: Action {
        Action("Paste", icon: .docOnClipboard) {
            UIPasteboard.general.asyncString()
                .uponQueue(.main) { SearchQueryModel.shared.value = $0.successValue as? String }
        }
    }
    private var pasteAndGoAction: Action {
        Action("Paste & Go", icon: .docOnClipboardFill) {
            UIPasteboard.general.asyncString()
                .uponQueue(.main) { ($0.successValue as? String).map(onSubmit) }
        }
    }

    var body: some View {
        let backgroundColor: Color = isIncognito
            ? isPressed ? .elevatedDarkBackground : .black
            : isPressed ? .tertiarySystemFill : .systemFill
        HStack {
            ZStack {
                Capsule().fill(backgroundColor)

                TabLocationAligner(transitionToEditing: searchQuery.isEditing) {
                    LocationLabel(url: $model.url, isSecure: model.isSecure)
                        .accessibilityAction(copyAction)
                        .accessibilityAction(pasteAction)
                        .accessibilityAction(pasteAndGoAction)
                } labelOverlay: { padding in
                    if !searchQuery.isEditing {
                        LocationViewTouchHandler(
                            margins: padding,
                            isPressed: $isPressed,
                            url: model.url,
                            isSecure: model.isSecure,
                            background: backgroundColor,
                            onTap: {
                                if let query = neevaSearchEngine.queryForLocationBar(from: model.url) {
                                    searchQuery.value = query
                                } else {
                                    // TODO: Decode punycode hostname.
                                    searchQuery.value = model.url?.absoluteString ?? ""
                                }
                            },
                            copyAction: copyAction,
                            pasteAction: pasteAction,
                            pasteAndGoAction: pasteAndGoAction
                        )
                    }
                } leading: {
                    if model.url?.scheme == "https" || model.url?.scheme == "http" {
                        LocationViewTrackingButton()
                    }
                } trailing: {
                    Group {
                        if model.readerMode != .active {
                            LocationViewReloadButton(buildMenu: buildReloadMenu, state: $model.reloadButton, onTap: onReload)
                        }
                        LocationViewShareButton(url: model.url, canShare: model.canShare, onTap: onShare)
                    }.transition(.move(edge: .trailing).combined(with: .opacity))
                }.opacity(searchQuery.isEditing ? 0 : 1)

                if searchQuery.isEditing {
                    LocationTextField(currentUrl: model.url, onSubmit: onSubmit, textField: $textField)
                }
            }
            .frame(height: TabLocationViewUX.height)
            .colorScheme(isIncognito ? .dark : colorScheme)
            if searchQuery.isEditing {
                Button {
                    searchQuery.value = nil
                    textField?.resignFirstResponder()
                } label: {
                    Text("Cancel").fontWeight(.medium)
                }
                .transition(.move(edge: .trailing))
                .accentColor(.ui.adaptive.blue)
            }
        }.animation(.spring(response: 0.3))
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            TabLocationView(model: URLBarModel(url: "http://vviii.verylong.subdomain.neeva.com"), onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
//            TabLocationView(model: URLBarModel(url: "https://neeva.com/asdf"), onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }).environment(\.isIncognito, true)
//            TabLocationView(model: URLBarModel(url: neevaSearchEngine.searchURLForQuery("a long search query with words")), onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
//            TabLocationView(model: URLBarModel(url: "ftp://someftpsite.com/dir/file.txt"), onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }).environment(\.isIncognito, true)
        }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
