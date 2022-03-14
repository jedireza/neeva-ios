// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI
import UIKit

enum SwipeDirection {
    case forward, back
}

public enum SwipeUX {
    static let EdgeWidth: CGFloat = 30
}

class SimulatedSwipeController:
    UIViewController, TabEventHandler, TabManagerDelegate, SimulateForwardAnimatorDelegate
{
    var model: SimulatedSwipeModel
    var animator: SimulatedSwipeAnimator!
    var superview: UIView!
    var blankView: UIView!
    var progressView: UIHostingController<CarouselProgressView>!
    private var viewHiddenSubscription: AnyCancellable?

    init(model: SimulatedSwipeModel, superview: UIView!) {
        self.model = model
        self.superview = superview
        super.init(nibName: nil, bundle: nil)

        register(self, forTabEvents: .didChangeURL)
        model.tabManager.addDelegate(self)

        self.animator = SimulatedSwipeAnimator(
            model: model,
            simulatedSwipeControllerView: self.view)
        self.animator.delegate = self

        if model.swipeDirection == .forward {
            self.progressView = UIHostingController(
                rootView: CarouselProgressView(model: model.progressModel))
            self.progressView.view.backgroundColor = .clear
        }
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

        viewHiddenSubscription = model.$hidden.sink { [unowned self] hidden in
            view.isHidden = hidden
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        blankView.makeEdges([.top, .bottom], equalTo: superview)
        blankView.makeWidth(equalTo: superview, withOffset: -SwipeUX.EdgeWidth)

        switch model.swipeDirection {
        case .forward:
            blankView.makeEdges(.trailing, equalTo: self.view)
        case .back:
            blankView.makeEdges(.leading, equalTo: self.view)
        }
    }

    func tab(_ tab: Tab, didChangeURL url: URL) {
        guard let url = tab.webView?.url, tab == model.tabManager.selectedTab else {
            return
        }

        switch model.swipeDirection {
        case .forward:
            if let query = SearchEngine.current.queryForSearchURL(url), !query.isEmpty {
                model.forwardUrlMap[tab.tabUUID] = []
                SearchResultsController.getSearchResults(for: query) { result in
                    switch result {
                    case .failure(let error):
                        let _ = error as NSError
                        self.updateForwardVisibility(id: tab.tabUUID, results: nil)
                    case .success(let results):
                        self.updateForwardVisibility(id: tab.tabUUID, results: results)
                    }
                }
            }

            guard let urls = model.forwardUrlMap[tab.tabUUID] else {
                return
            }

            guard let index = urls?.firstIndex(of: url), index < (urls?.count ?? 0) - 1 else {
                self.updateForwardVisibility(id: tab.tabUUID, results: nil)
                return
            }

            model.progressModel.index = index
        case .back:
            updateBackVisibility(tab: tab)
        }

    }

    func tabManager(
        _ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?,
        isRestoring: Bool, updateZeroQuery: Bool
    ) {
        guard let tabUUID = selected?.tabUUID else {
            return
        }

        switch model.swipeDirection {
        case .forward:
            updateForwardVisibility(id: tabUUID, results: model.forwardUrlMap[tabUUID] ?? nil)
        case .back:
            updateBackVisibility(tab: selected)
        }
    }

    func updateBackVisibility(tab: Tab?) {
        guard let tab = tab else {
            model.hidden = true
            return
        }

        if tab.canGoBack {
            model.hidden = true
        } else if let _ = tab.parent {
            model.hidden = false
            model.chromeModel.canGoBack = true
        } else if let id = tab.parentSpaceID, !id.isEmpty {
            model.hidden = false
            model.chromeModel.canGoBack = true
        }
    }

    func updateForwardVisibility(id: String, results: [URL]?, index: Int = -1) {
        model.forwardUrlMap[id] = results
        model.hidden = results == nil
        model.chromeModel.canGoForward = !model.hidden

        guard let results = results else {
            progressView.view.removeFromSuperview()
            progressView.removeFromParent()
            model.progressModel.urls = []
            model.progressModel.index = 0
            return
        }

        let bvc = SceneDelegate.getBVC(for: view)
        bvc.addChild(progressView)
        bvc.view.addSubview(progressView.view)
        progressView.didMove(toParent: bvc)
        model.progressModel.urls = results
        model.progressModel.index = index

        progressView.view.makeEdges([.leading, .trailing], equalTo: self.view.superview)
        progressView.view.makeEdges(
            .bottom, equalTo: self.view, withOffset: -UIConstants.BottomToolbarHeight)
    }

    func simulateForwardAnimatorStartedSwipe(_ animator: SimulatedSwipeAnimator) {
        if model.swipeDirection == .forward {
            model.goForward()
        }
    }

    func simulateForwardAnimatorFinishedSwipe(_ animator: SimulatedSwipeAnimator) {
        if model.swipeDirection == .back {
            model.goBack()
        }
    }
}
