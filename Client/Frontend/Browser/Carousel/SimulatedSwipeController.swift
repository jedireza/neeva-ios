// Copyright Neeva. All rights reserved.

import UIKit

enum SwipeDirection {
    case forward, back
}

struct SimulatedSwipeUX {
    static let EdgeWidth:CGFloat = 30
}

class SimulatedSwipeController:
    UIViewController, TabEventHandler, TabManagerDelegate, SimulateForwardAnimatorDelegate {

    func simulateForwardAnimatorStartedSwipe(_ animator: SimulatedSwipeAnimator) {
        self.goForward()
    }

    func simulateForwardAnimatorFinishedSwipe(_ animator: SimulatedSwipeAnimator) {
        self.goBack()
    }

    var animator: SimulatedSwipeAnimator!
    var blankView: UIView!
    var tabManager: TabManager
    var navigationToolbar: TabToolbarProtocol
    var forwardUrlMap = [String: [URL]?]()
    var swipeDirection: SwipeDirection

    init(tabManager: TabManager, navigationToolbar: TabToolbarProtocol, swipeDirection: SwipeDirection) {
        self.tabManager = tabManager
        self.navigationToolbar = navigationToolbar
        self.swipeDirection = swipeDirection
        super.init(nibName: nil, bundle: nil)

        register(self, forTabEvents: .didChangeURL)
        tabManager.addDelegate(self)

        self.animator = SimulatedSwipeAnimator(
            swipeDirection: swipeDirection,
            animatingView: self.view,
            webViewContainer: BrowserViewController.foregroundBVC().webViewContainer)
        self.animator.delegate = self

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        blankView = UIView()
        blankView.backgroundColor = .white
        self.view.addSubview(blankView)

        blankView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-SimulatedSwipeUX.EdgeWidth)

            switch swipeDirection {
            case .forward:
                make.trailing.equalToSuperview()
            case .back:
                make.leading.equalToSuperview()
            }
        }
    }

    func tab(_ tab: Tab, didChangeURL url: URL) {
        guard let url = tab.webView?.url, tab == tabManager.selectedTab  else {
            return
        }

        switch swipeDirection {
        case .forward:
            if let query = neevaSearchEngine.queryForSearchURL(url), !query.isEmpty {
                forwardUrlMap[tab.tabUUID] = []
                SearchResultsController.getSearchResults(for: query) {result in
                    switch result {
                    case .failure(let error):
                        let _ = error as NSError
                        self.updateForwardVisibility(id: tab.tabUUID, results: nil)
                    case .success(let results):
                        self.updateForwardVisibility(id: tab.tabUUID, results: results)
                    }
                }
            }

            guard let urls = self.forwardUrlMap[tab.tabUUID] else {
                return
            }

            guard let index = urls?.firstIndex(of: url), index < (urls?.count ?? 0 - 2) else {
                self.updateForwardVisibility(id: tab.tabUUID, results: nil)
                return
            }
        case .back:
            updateBackVisibility(tab: tab)
        }

    }

    func tabManager(_ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?, isRestoring: Bool) {
        guard let tabUUID = selected?.tabUUID else {
            return
        }

        switch swipeDirection {
        case .forward:
            updateForwardVisibility(id: tabUUID, results: self.forwardUrlMap[tabUUID] ?? nil )
        case .back:
            updateBackVisibility(tab: selected)
        }
    }

    func updateBackVisibility(tab: Tab?) {
        guard let _ = tab?.parent, !(tab?.canGoBack ?? true) else {
            view.isHidden = true
            return
        }

        view.isHidden = false
        navigationToolbar.updateBackStatus(true)
    }

    func updateForwardVisibility(id: String, results: [URL]?) {
        forwardUrlMap[id] = results
        view.isHidden = results == nil
        navigationToolbar.updateForwardStatus(!view.isHidden)
    }

    func canGoBack() -> Bool {
        swipeDirection == .back && !view.isHidden
    }

    @discardableResult func goBack() -> Bool {
        guard canGoBack(), swipeDirection == .back, let tab = tabManager.selectedTab else {
            return false
        }

        tabManager.removeTabAndUpdateSelectedIndex(tab)
        return true
    }

    func canGoForward() -> Bool {
        swipeDirection == .forward && !view.isHidden
    }

    @discardableResult func goForward() -> Bool {
        guard canGoForward(), swipeDirection == .forward, let tab = tabManager.selectedTab,
              let urls = forwardUrlMap[tab.tabUUID]! else {
            return false
        }

        let index = urls.firstIndex(of: tab.currentURL()!) ?? 0
        assert(index < urls.count - 1) // If we are here, we have already fake animated and it is too late
        tab.loadRequest(URLRequest(url: urls[index + 1]))
        return true
    }

    func tabManager(_ tabManager: TabManager, didAddTab tab: Tab, isRestoring: Bool) {}

    func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool) {}

    func tabManagerDidRestoreTabs(_ tabManager: TabManager) {}

    func tabManagerDidAddTabs(_ tabManager: TabManager) {}

    func tabManagerDidRemoveAllTabs(_ tabManager: TabManager, toast: ButtonToast?) {}
}
