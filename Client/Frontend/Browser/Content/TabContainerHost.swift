// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import Storage
import SwiftUI

enum ContentUIType: Equatable {
    case webPage(WKWebView)
    case zeroQuery
    case suggestions
    case blank
    case previewHome
}

enum ContentUIVisibilityEvent {
    case showZeroQuery(isIncognito: Bool, isLazyTab: Bool, ZeroQueryOpenedLocation?)
    case hideZeroQuery
    case showSuggestions
    case hideSuggestions
    case showPreviewHome
}

class TabContainerModel: ObservableObject {
    /// Holds the current webpage's WebView, so that when the state changes to be other content, we don't lose it.
    @Published private(set) var webContainerType: ContentUIType {
        didSet {
            switch currentContentUI {
            case .webPage:
                currentContentUI = webContainerType
            case .blank:
                currentContentUI = webContainerType
            default:
                return
            }
        }
    }
    /// Current content UI that is showing
    @Published private(set) var currentContentUI: ContentUIType

    @Published private(set) var recipeModel: RecipeViewModel

    private var subscription: AnyCancellable? = nil

    private let zeroQueryModel: ZeroQueryModel
    let tabCardModel: TabCardModel

    init(bvc: BrowserViewController) {
        let tabManager = bvc.tabManager
        let webView = tabManager.selectedTab?.webView
        let type = webView.map(ContentUIType.webPage) ?? Self.defaultType

        self.webContainerType = type
        self.currentContentUI = type
        self.recipeModel = RecipeViewModel(tabManager: tabManager)
        self.zeroQueryModel = bvc.zeroQueryModel
        self.tabCardModel = TabCardModel(
            manager: tabManager, groupManager: TabGroupManager(tabManager: tabManager))

        self.subscription = tabManager.selectedTabPublisher.sink { [weak self] tab in
            guard let self = self else { return }
            guard let webView = tab?.webView else {
                self.webContainerType = .blank
                return
            }

            self.webContainerType = .webPage(webView)

            if NeevaFeatureFlags[.recipeCheatsheet] && !tabManager.isIncognito {
                if let url = webView.url {
                    self.recipeModel.updateContentWithURL(url: url)
                    bvc.chromeModel.currentCheatsheetFaviconURL =
                        tabManager.selectedTab?.favicon?.url
                    bvc.chromeModel.currentCheatsheetURL = tabManager.selectedTab?.url
                }
            }
        }
    }

    static var defaultType: ContentUIType {
        // TODO(darin): We should get rid of the notion of .blank. We should be showing the empty
        // card grid in this case instead.
        !Defaults[.didFirstNavigation] ? .previewHome : .blank
    }

    func updateContent(_ event: ContentUIVisibilityEvent) {
        switch event {
        case .showZeroQuery(let isIncognito, let isLazyTab, let openedFrom):
            currentContentUI = .zeroQuery
            zeroQueryModel.isPrivate = isIncognito
            zeroQueryModel.isLazyTab = isLazyTab
            zeroQueryModel.openedFrom = openedFrom
            if openedFrom == .newTabButton {
                zeroQueryModel.targetTab = .newTab
            }
        case .showSuggestions:
            if case .zeroQuery = currentContentUI {
                currentContentUI = .suggestions
            }
        case .hideSuggestions:
            if case .suggestions = currentContentUI {
                currentContentUI = .zeroQuery
                zeroQueryModel.targetTab = .defaultValue
            }
        case .hideZeroQuery:
            if !Defaults[.didFirstNavigation] {
                currentContentUI = .previewHome
            } else {
                currentContentUI = webContainerType
            }
        case .showPreviewHome:
            currentContentUI = .previewHome
        }
    }
}

struct TabContainerContent: View {
    @ObservedObject var model: TabContainerModel
    let bvc: BrowserViewController
    let zeroQueryModel: ZeroQueryModel
    let suggestionModel: SuggestionModel
    let suggestedSearchesModel: SuggestedSearchesModel =
        SuggestedSearchesModel(suggestedQueries: [])
    let spaceContentSheetModel: SpaceContentSheetModel?

    var yOffset: CGFloat {
        guard let scrollingController = bvc.scrollController, !FeatureFlag[.enableBrowserView]
        else {
            return 0.02
        }

        return scrollingController.headerTopOffset
            / scrollingController.headerHeight
    }

    var body: some View {
        ZStack {
            // MARK: Page Content
            switch model.currentContentUI {
            case .webPage(let currentWebView):
                ZStack {
                    WebViewContainer(webView: currentWebView)
                        .ignoresSafeArea()
                        .onTapGesture {
                            UIMenuController.shared.hideMenu()
                        }

                    if FeatureFlag[.cardStrip] && !FeatureFlag[.topCardStrip]
                        && UIDevice.current.useTabletInterface
                    {
                        GeometryReader { geo in
                            VStack {
                                Spacer()
                                CardStripContent(bvc: bvc, width: geo.size.width)
                            }
                        }
                    }

                    if FeatureFlag[.spaceComments] {
                        SpaceContentSheet(
                            model: spaceContentSheetModel!,
                            yOffset: yOffset
                        )
                        .environment(
                            \.onOpenURLForSpace,
                            { bvc.tabManager.createOrSwitchToTabForSpace(for: $0, spaceID: $1) }
                        )
                    }

                    if NeevaFeatureFlags[.recipeCheatsheet]
                        && !bvc.tabManager.isIncognito && NeevaUserInfo.shared.hasLoginCookie()
                    {
                        GeometryReader { geo in
                            VStack {
                                Spacer()

                                RecipeCheatsheetStripView(
                                    tabManager: bvc.tabManager,
                                    recipeModel: model.recipeModel,
                                    yOffset: yOffset,
                                    height: geo.size.height,
                                    chromeModel: bvc.chromeModel,
                                    overlayManager: bvc.overlayManager
                                )
                                .environment(\.onOpenURL) { url in
                                    let bvc = zeroQueryModel.bvc
                                    bvc.tabManager.createOrSwitchToTab(for: url)
                                }
                            }
                        }
                    }
                }
            case .previewHome:
                PreviewHomeView(bvc: bvc)
                    .environment(\.onOpenURL) { url in
                        bvc.tabManager.createOrSwitchToTab(for: url)
                    }
            case .blank:
                ZeroQueryContent(model: zeroQueryModel)
                    .environmentObject(suggestedSearchesModel)
            default:
                Color.clear
            }

            // MARK: Overlays
            if model.currentContentUI == .zeroQuery || model.currentContentUI == .suggestions {
                ZStack {
                    switch model.currentContentUI {
                    case .zeroQuery:
                        ZeroQueryContent(model: zeroQueryModel)
                            .transition(.identity)
                            .environmentObject(suggestedSearchesModel)
                    case .suggestions:
                        SuggestionsContent(suggestionModel: suggestionModel)
                            .transition(.identity)
                            .environment(\.onOpenURL) { url in
                                let bvc = zeroQueryModel.bvc
                                guard let tab = bvc.tabManager.selectedTab else { return }
                                bvc.finishEditingAndSubmit(
                                    url, visitType: VisitType.typed, forTab: tab)
                            }.environment(\.setSearchInput) { suggestion in
                                suggestionModel.queryModel.value = suggestion
                            }.environment(\.onSigninOrJoinNeeva) {
                                ClientLogger.shared.logCounter(
                                    .SuggestionErrorSigninOrJoinNeeva,
                                    attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                                let bvc = zeroQueryModel.bvc
                                bvc.chromeModel.setEditingLocation(to: false)
                                bvc.presentIntroViewController(
                                    true,
                                    onDismiss: {
                                        bvc.hideCardGrid(withAnimation: true)
                                    }
                                )
                            }
                    default:
                        EmptyView()
                    }
                }
                .transition(.pageOverlay)
            }
        }.useEffect(deps: model.currentContentUI) { _ in
            zeroQueryModel.profile.panelDataObservers.activityStream.refreshIfNeeded(
                forceTopSites: true)
            self.zeroQueryModel.updateSuggestedSites()
            self.suggestedSearchesModel.reload(from: zeroQueryModel.profile)
        }.animation(.spring(), value: model.currentContentUI)
    }
}

class TabContainerHost: IncognitoAwareHostingController<TabContainerContent> {
    init(model: TabContainerModel, bvc: BrowserViewController) {
        super.init(isIncognito: bvc.tabManager.isIncognito) {
            TabContainerContent(
                model: model,
                bvc: bvc,
                zeroQueryModel: bvc.zeroQueryModel,
                suggestionModel: bvc.suggestionModel,
                spaceContentSheetModel: FeatureFlag[.spaceComments]
                    ? SpaceContentSheetModel(
                        tabManager: bvc.tabManager,
                        spaceModel: bvc.gridModel.spaceCardModel) : nil)
        }
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
