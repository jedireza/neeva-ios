// Copyright Neeva. All rights reserved.

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
    @Published var webContainerType: ContentUIType {
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
    @Published var currentContentUI: ContentUIType

    @Published var recipeModel: RecipeViewModel

    var subscription: AnyCancellable? = nil

    let zeroQueryModel: ZeroQueryModel
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

    @discardableResult public func promoteToRealTabIfNecessary(
        url: URL, tabManager: TabManager, selectedTabIsNil: Bool = false, searchQuery: String?
    ) -> Bool {
        let result = zeroQueryModel.promoteToRealTabIfNecessary(
            url: url, tabManager: tabManager, searchQuery: searchQuery)
        if result {
            updateContent(.hideZeroQuery)
        }

        return selectedTabIsNil || result
    }

    func updateContent(_ event: ContentUIVisibilityEvent) {
        switch event {
        case .showZeroQuery(let isIncognito, let isLazyTab, let openedFrom):
            currentContentUI = .zeroQuery
            zeroQueryModel.isPrivate = isIncognito
            zeroQueryModel.isLazyTab = isLazyTab
            zeroQueryModel.openedFrom = openedFrom
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
                zeroQueryModel.reset(bvc: nil)
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

    var body: some View {
        Group {
            switch model.currentContentUI {
            case .webPage(let currentWebView):
                ZStack {
                    WebViewContainer(webView: currentWebView)
                        .ignoresSafeArea()

                    if FeatureFlag[.cardStrip] && !FeatureFlag[.topCardStrip] {
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
                            scrollingController: bvc.scrollController
                        )
                        .environment(
                            \.onOpenURLForSpace,
                            { bvc.tabManager.createOrSwitchToTabForSpace(for: $0, spaceID: $1) }
                        )
                    }
                    if NeevaFeatureFlags[.recipeCheatsheet] && !bvc.tabManager.isIncognito
                        && NeevaUserInfo.shared.hasLoginCookie()
                    {
                        GeometryReader { geo in
                            VStack {
                                Spacer()
                                RecipeCheatsheetStripView(
                                    tabManager: bvc.tabManager,
                                    recipeModel: model.recipeModel,
                                    scrollingController: bvc.scrollController,
                                    height: geo.size.height,
                                    chromeModel: bvc.chromeModel
                                )
                                .environment(\.onOpenURL) { url in
                                    let bvc = zeroQueryModel.bvc
                                    bvc.tabManager.createOrSwitchToTab(for: url)
                                }
                            }
                        }
                    }
                }
            case .zeroQuery:
                ZeroQueryContent(model: zeroQueryModel)
                    .environmentObject(suggestedSearchesModel)
            case .suggestions:
                SuggestionsContent(suggestionModel: suggestionModel)
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
            case .blank:
                ZeroQueryContent(model: zeroQueryModel)
                    .environmentObject(suggestedSearchesModel)
            case .previewHome:
                PreviewHomeView(bvc: bvc)
                    .environment(\.onOpenURL) { url in
                        bvc.tabManager.createOrSwitchToTab(for: url)
                    }
            }
        }.useEffect(deps: model.currentContentUI) { _ in
            zeroQueryModel.profile.panelDataObservers.activityStream.refreshIfNeeded(
                forceTopSites: true)
            self.zeroQueryModel.updateSuggestedSites()
            self.suggestedSearchesModel.reload(from: zeroQueryModel.profile)
        }
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

        bvc.suggestionModel.getKeyboardHeight = {
            if let view = self.view,
                let currentState = KeyboardHelper.defaultHelper.currentState
            {
                // Minus extra padding which is added by the system above the keyboard in landscape mode
                return currentState.intersectionHeightForView(view)
                    - (UIDevice.current.orientation.isLandscape
                        ? (UIDevice.current.userInterfaceIdiom == .pad ? 28 : 16) : 0)
            } else {
                return 0
            }
        }
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
