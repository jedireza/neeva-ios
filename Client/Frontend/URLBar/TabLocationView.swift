// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults
import UniformTypeIdentifiers

enum TabLocationViewUX {
    static let height: CGFloat = 42
    static let placeholder = Text("Search or enter address")
}

// note: explicitly ignores the disabled state
fileprivate struct TabLocationButtonStyle: ButtonStyle {
    let isDropping: Bool

    struct Body: View {
        let configuration: Configuration
        let isDropping: Bool

        @Environment(\.isIncognito) private var isIncognito

        var body: some View {
            let highlight = configuration.isPressed || isDropping
            configuration.label
                .foregroundColor(
                    isIncognito
                        ? highlight ? .elevatedDarkBackground : .black
                        : highlight ? .tertiarySystemFill : .systemFill
                )
        }
    }
    func makeBody(configuration: Configuration) -> Body {
        Body(configuration: configuration, isDropping: isDropping)
    }
}

struct TabLocationView: View {
    @ObservedObject var model: URLBarModel
    let onReload: () -> ()
    let onSubmit: (String) -> ()
    let onShare: (UIView) -> ()
    let buildReloadMenu: () -> UIMenu?

    // TODO: when removing support for iOS 14, change this to a Bool to manage focus
    @State private var textField: UITextField?

    @State private var showingMenu = false
    @State private var isDropping = false

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
                .uponQueue(.main) { model.text = $0.successValue as? String }
        }
    }
    private var pasteAndGoAction: Action {
        Action("Paste & Go", icon: .docOnClipboardFill) {
            UIPasteboard.general.asyncString()
                .uponQueue(.main) { ($0.successValue as? String).map(onSubmit) }
        }
    }

    var body: some View {
        let isEditing = model.text != nil
        HStack {
            Button(action: {
                if showingMenu {
                    showingMenu = false
                } else if let query = neevaSearchEngine.queryForLocationBar(from: model.url) {
                    model.text = query
                } else {
                    // TODO: Decode punycode hostname.
                    model.text = model.url?.absoluteString ?? ""
                }
            }) {
                Capsule()
            }
            .disabled(isEditing || showingMenu)
            .buttonStyle(TabLocationButtonStyle(isDropping: isDropping))
            .accessibilityHidden(true)
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in showingMenu = true }
            )
            .background(
                LocationViewMenu(
                    isVisible: $showingMenu,
                    copyAction: copyAction,
                    pasteAction: pasteAction,
                    pasteAndGoAction: pasteAndGoAction
                )
            )
            .overlay(TabLocationAligner(transitionToEditing: isEditing) {
                LocationLabel(url: $model.url, isSecure: model.isSecure)
                    .accessibilityAction(copyAction)
                    .accessibilityAction(pasteAction)
                    .accessibilityAction(pasteAndGoAction)
            } leading: {
                LocationViewTrackingButton()
            } trailing: {
                Group {
                    if model.readerMode != .active {
                        LocationViewReloadButton(buildMenu: buildReloadMenu, state: $model.reloadButton, onTap: onReload)
                    }
                    LocationViewShareButton(url: model.url, canShare: model.canShare, onTap: onShare)
                }.transition(.move(edge: .trailing).combined(with: .opacity))
            }.opacity(isEditing ? 0 : 1))
            .overlay(Group {
                if isEditing {
                    LocationTextField(text: $model.text, onSubmit: onSubmit, textField: $textField)
                }
            })
            .onDrop(of: [.url], isTargeted: $isDropping) { providers in
                guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) })
                else { return false }
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            onSubmit(url.absoluteString)
                        }
                    }
                }
                return false
            }
            .if(model.url != nil && !isEditing) {
                (print("mounting onDrag"), $0.onDrag {
                    NSItemProvider(object: model.url! as NSItemProviderWriting)
                }).1
            }
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
            TabLocationView(model: URLBarModel(url: "http://vviii.verylong.subdomain.neeva.com"), onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
            TabLocationView(model: URLBarModel(url: "https://neeva.com/asdf"), onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }).environment(\.isIncognito, true)
            TabLocationView(model: URLBarModel(url: neevaSearchEngine.searchURLForQuery("a long search query with words")), onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil })
            TabLocationView(model: URLBarModel(url: "ftp://someftpsite.com/dir/file.txt"), onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }).environment(\.isIncognito, true)
        }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
