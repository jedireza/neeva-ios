// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults
import UniformTypeIdentifiers

enum TabLocationViewUX {
    static let height: CGFloat = 42
    static let placeholder = Text("Search or enter address")
    static let textFieldOffset: CGFloat = 75
}

struct OffsetModifier: ViewModifier {
    let x: CGFloat
    func body(content: Content) -> some View {
        content.offset(x: x, y: 0)
    }
}

struct TabLocationView: View {
    let onReload: () -> ()
    let onSubmit: (String) -> ()
    let onShare: (UIView) -> ()
    let buildReloadMenu: () -> UIMenu?

    @EnvironmentObject private var model: URLBarModel
    @State private var isPressed = false
    @Environment(\.isIncognito) private var isIncognito
    @Environment(\.colorScheme) private var colorScheme

    @State var token = 0

    private var copyAction: Action {
        Action("Copy", icon: .docOnDoc) {
            UIPasteboard.general.url = model.url
        }
    }
    private var pasteAction: Action {
        Action("Paste", icon: .docOnClipboard) {
            UIPasteboard.general.asyncString()
                .uponQueue(.main) {
                    if let query = $0.successValue as? String {
                        SearchQueryModel.shared.value = query
                        model.isEditing = true
                    }
                }
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

                TabLocationAligner(transitionToEditing: model.isEditing) {
                    LocationLabel(url: model.url, isSecure: model.isSecure)
                        .accessibilityAction(copyAction)
                        .accessibilityAction(pasteAction)
                        .accessibilityAction(pasteAndGoAction)
                } labelOverlay: { padding in
                    if !model.isEditing {
                        LocationViewTouchHandler(
                            margins: padding,
                            isPressed: $isPressed,
                            url: model.url,
                            isSecure: model.isSecure,
                            background: backgroundColor,
                            onTap: {
                                if let query = neevaSearchEngine.queryForLocationBar(from: model.url) {
                                    SearchQueryModel.shared.value = query
                                } else {
                                    // TODO: Decode punycode hostname.
                                    SearchQueryModel.shared.value = model.url?.absoluteString ?? ""
                                }
                                model.isEditing = true
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
                    }.transition(.opacity)
                }.opacity(model.isEditing ? 0 : 1)

                HStack(spacing: 0) {
                    if model.isEditing {
                        LocationTextFieldIcon(currentUrl: model.url)
                            .frame(width: TabLocationViewUX.height)
                            .transition(.opacity)
                        LocationEditView(isEditing: $model.isEditing, onSubmit: onSubmit)
                            // force the view to be recreated each time edit mode is entered
                            .id(token)
                            .transition(.modifier(active: OffsetModifier(x: TabLocationViewUX.textFieldOffset), identity: OffsetModifier(x: 0)).combined(with: .opacity))
                    }
                }
            }
            .frame(height: TabLocationViewUX.height)
            .colorScheme(isIncognito ? .dark : colorScheme)
            .onChange(of: model.isEditing) { isEditing in
                if !isEditing {
                    token += 1
                }
            }

            if model.isEditing {
                Button {
                    model.isEditing = false
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
            TabLocationView(onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
                .environmentObject(URLBarModel(previewURL: nil, isSecure: true))
                .previewDisplayName("Placeholder")

            TabLocationView(onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
                .environmentObject(URLBarModel(previewURL: "http://vviii.verylong.verylong.subdomain.neeva.com", isSecure: true))
                .previewDisplayName("Long domain")
            TabLocationView(onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
                .environment(\.isIncognito, true)
                .environmentObject(URLBarModel(previewURL: "https://neeva.com/asdf", isSecure: false))
                .previewDisplayName("Incognito")
            TabLocationView(onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
                .environmentObject(URLBarModel(previewURL: neevaSearchEngine.searchURLForQuery("a long search query with words"), isSecure: true))
                .previewDisplayName("Search")
            TabLocationView(onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
                .environment(\.isIncognito, true)
                .environmentObject(URLBarModel(previewURL: "ftp://someftpsite.com/dir/file.txt", isSecure: false))
                .previewDisplayName("Non-HTTP")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
