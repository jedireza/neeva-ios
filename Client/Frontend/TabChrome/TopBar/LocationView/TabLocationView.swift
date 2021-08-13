// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI
import UniformTypeIdentifiers

enum TabLocationViewUX {
    static let height: CGFloat = 42
    static let placeholder = Text("Search or enter address")
    static let textFieldOffset: CGFloat = 75
    static let animation = Animation.spring(response: 0.3)
}

struct OffsetModifier: ViewModifier {
    let x: CGFloat
    func body(content: Content) -> some View {
        content.offset(x: x, y: 0)
    }
}

struct TabLocationView: View {
    let onReload: () -> Void
    let onSubmit: (String) -> Void
    let onShare: (UIView) -> Void
    let buildReloadMenu: () -> UIMenu?

    @EnvironmentObject private var model: LocationViewModel
    @EnvironmentObject private var chromeModel: TabChromeModel
    @EnvironmentObject private var suggestionModel: SuggestionModel
    @EnvironmentObject private var queryModel: SearchQueryModel
    @EnvironmentObject private var gridModel: GridModel
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
                        queryModel.value = query
                        chromeModel.setEditingLocation(to: true)
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
        let backgroundColor: Color =
            isIncognito
            ? isPressed ? .elevatedDarkBackground : .black
            : isPressed ? .tertiarySystemFill : .systemFill
        HStack(spacing: 11) {
            ZStack {
                Capsule().fill(backgroundColor)

                TabLocationAligner(transitionToEditing: chromeModel.isEditingLocation) {
                    LocationLabel(url: model.url, isSecure: model.isSecure)
                        .accessibilityAction(copyAction)
                        .accessibilityAction(pasteAction)
                        .accessibilityAction(pasteAndGoAction)
                } labelOverlay: { padding in
                    if !chromeModel.isEditingLocation {
                        LocationViewTouchHandler(
                            margins: padding,
                            isPressed: $isPressed,
                            url: model.url,
                            isSecure: model.isSecure,
                            background: backgroundColor,
                            onTap: {
                                if let query = neevaSearchEngine.queryForLocationBar(
                                    from: model.url)
                                {
                                    queryModel.value = query
                                } else {
                                    // TODO: Decode punycode hostname.
                                    queryModel.value = model.url?.absoluteString ?? ""
                                }
                                chromeModel.setEditingLocation(to: true)
                            },
                            copyAction: copyAction,
                            pasteAction: pasteAction,
                            pasteAndGoAction: pasteAndGoAction
                        )
                    }
                } leading: {
                    if gridModel.isHidden
                        && (model.url?.scheme == "https" || model.url?.scheme == "http")
                    {
                        LocationViewTrackingButton(currentDomain: model.url?.baseDomain ?? "")
                    }
                } trailing: {
                    if gridModel.isHidden {
                        Group {
                            if model.readerMode != .active, let url = model.url,
                                !InternalURL.isValid(url: url), !FeatureFlag[.overflowMenu]
                            {
                                LocationViewReloadButton(
                                    buildMenu: buildReloadMenu, state: chromeModel.reloadButton,
                                    onTap: onReload)
                            }
                            if chromeModel.isPage, !chromeModel.inlineToolbar {
                                LocationViewShareButton(url: model.url, onTap: onShare)
                            }
                        }.transition(.opacity)
                    }
                }.opacity(chromeModel.isEditingLocation ? 0 : 1)

                HStack(spacing: 0) {
                    if chromeModel.isEditingLocation {
                        LocationTextFieldIcon(currentUrl: model.url)
                            .transition(.opacity)
                        LocationEditView(
                            isEditing: Binding(
                                get: { chromeModel.isEditingLocation },
                                set: chromeModel.setEditingLocation(to:)), onSubmit: onSubmit
                        )
                        // force the view to be recreated each time edit mode is entered
                        .id(token)
                        .transition(
                            .modifier(
                                active: OffsetModifier(x: TabLocationViewUX.textFieldOffset),
                                identity: OffsetModifier(x: 0)
                            ).combined(with: .opacity))
                    }
                }
            }
            .frame(height: TabLocationViewUX.height)
            .colorScheme(isIncognito ? .dark : colorScheme)
            .onChange(of: chromeModel.isEditingLocation) { isEditing in
                if !isEditing {
                    token += 1
                }
            }

            if chromeModel.isEditingLocation {
                Button {
                    SceneDelegate.getBVC().closeLazyTab()
                    chromeModel.setEditingLocation(to: false)
                } label: {
                    Text("Cancel").withFont(.bodyLarge)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .accentColor(.ui.adaptive.blue)
            }
        }
    }
}

struct TabLocationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }
            )
            .environmentObject(LocationViewModel(previewURL: nil, hasOnlySecureContent: true))
            .previewDisplayName("Placeholder")

            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }
            )
            .environmentObject(
                LocationViewModel(
                    previewURL: "http://vviii.verylong.verylong.subdomain.neeva.com", hasOnlySecureContent: true
                )
            )
            .previewDisplayName("Long domain")
            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }
            )
            .environment(\.isIncognito, true)
            .environmentObject(
                LocationViewModel(previewURL: "https://neeva.com/asdf", hasOnlySecureContent: nil)
            )
            .previewDisplayName("Incognito")
            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }
            )
            .environmentObject(
                LocationViewModel(
                    previewURL: neevaSearchEngine.searchURLForQuery(
                        "a long search query with words"), hasOnlySecureContent: true)
            )
            .previewDisplayName("Search")
            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }
            )
            .environment(\.isIncognito, true)
            .environmentObject(
                LocationViewModel(previewURL: "ftp://someftpsite.com/dir/file.txt", hasOnlySecureContent: nil)
            )
            .previewDisplayName("Non-HTTP")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
