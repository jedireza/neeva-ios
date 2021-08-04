// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct OverflowMenuRootView: View {
    @StateObject var overlaySheetModel = OverlaySheetModel()
    let onDismiss: () -> Void
    let isIncognito: Bool
    var embeddedView: OverflowMenuView

    let tabToolbarModel: TabToolbarModel
    let urlBarModel: URLBarModel

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            self.embeddedView
                .environment(\.isIncognito, isIncognito)
                .environmentObject(tabToolbarModel)
                .environmentObject(urlBarModel)
                .overlaySheetIsFixedHeight(isFixedHeight: true).padding(.top, 8)
        }
        .onAppear {
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class OverflowMenuViewController: UIHostingController<OverflowMenuRootView> {
    var delegate: BrowserViewController?

    public init(
        delegate: BrowserViewController, onDismiss: @escaping () -> Void, isPrivate: Bool,
        feedbackImage: UIImage?,
        tabToolbarModel: TabToolbarModel,
        urlBarModel: URLBarModel
    ) {
        super.init(
            rootView: OverflowMenuRootView(
                onDismiss: onDismiss, isIncognito: isPrivate,
                embeddedView: OverflowMenuView(noTopPadding: true, changedUserAgent: delegate.tabManager.selectedTab?.changedUserAgent ?? false, menuAction: nil), tabToolbarModel: tabToolbarModel, urlBarModel: urlBarModel))

        self.delegate = delegate
        delegate.isNeevaMenuSheetOpen = true
        self.view.accessibilityViewIsModal = true

        //Build callbacks for each button action
        let embeddedView = OverflowMenuView(noTopPadding: true, changedUserAgent: delegate.tabManager.selectedTab?.changedUserAgent ?? false) { result in
            delegate.isNeevaMenuSheetOpen = false
            self.rootView.onDismiss()
            switch result {
            case .forward:
                delegate.tabToolbarDidPressForward()
                break
            case .reload:
                delegate.tabManager.selectedTab!.reload()
                break
            case .newTab:
                delegate.openLazyTab()
                break
            case .findOnPage:
                delegate.updateFindInPageVisibility(visible: true)
                break
            case .textSize:
                let sheet = UIHostingController(
                    rootView: ZoomMenuView(
                        model: ZoomMenuModel(webView: delegate.tabManager.selectedTab!.webView!),
                        onDismiss: { [delegate] in
                            delegate.presentedViewController?.dismiss(animated: true, completion: nil)
                        }
                    )
                )
                sheet.modalPresentationStyle = .overFullScreen
                sheet.view.isOpaque = false
                sheet.view.backgroundColor = .clear
                delegate.present(sheet, animated: true, completion: nil)
                break
            case .readingMode:
                if let tab = delegate.tabManager.selectedTab,
                    let readerMode = tab.getContentScript(name: "ReaderMode") as? ReaderMode,
                    readerMode.state != .unavailable,
                    FeatureFlag[.readingMode]
                {
                    let readingModeActivity = ReadingModeActivity(readerModeState: readerMode.state) {
                        switch readerMode.state {
                        case .available:
                            delegate.enableReaderMode()
                        case .active:
                            delegate.disableReaderMode()
                        case .unavailable:
                            break
                        }
                    }
                }
                break
            case .desktopSite:
                if let url = delegate.tabManager.selectedTab?.url {
                    delegate.tabManager.selectedTab?.toggleChangeUserAgent()
                    Tab.ChangeUserAgent.updateDomainList(
                        forUrl: url, isChangedUA: delegate.tabManager.selectedTab?.changedUserAgent ?? false,
                        isPrivate: delegate.tabManager.selectedTab?.isPrivate ?? false)
                }
                break
            }
        }
        self.rootView = OverflowMenuRootView(
            onDismiss: onDismiss, isIncognito: isPrivate, embeddedView: embeddedView, tabToolbarModel: tabToolbarModel, urlBarModel: urlBarModel)
    }

    private func spacesHandler(_ delegate: BrowserViewController) {
        // Without this rootView.onDismiss, Neeva menu sheet would not hide
        // after navigating to spaces page. User will still see the Neeva
        // menu sheet open
        self.rootView.onDismiss()
        ClientLogger.shared.logCounter(
            .OpenSpaces, attributes: EnvironmentHelper.shared.getAttributes())

        // if user started a tour, trigger navigation on webui side
        // to prevent page refresh, which will lost the states
        if TourManager.shared.userReachedStep(step: .promptSpaceInNeevaMenu) != .stopAction {
            delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.spaces)
        }
    }

    private func settingsHandler(_ delegate: BrowserViewController) {
        ClientLogger.shared.logCounter(
            .OpenSetting, attributes: EnvironmentHelper.shared.getAttributes())
        TourManager.shared.userReachedStep(tapTarget: .settingMenu)

        // Without this dismiss, when user click on settings menu, if there is
        // a quest prompt display on top of it, settings panel would not
        // show up
        self.dismiss(animated: true, completion: nil)

        let controller = SettingsViewController(bvc: delegate)

        // Wait to present VC in an async dispatch queue to prevent a case where dismissal
        // of this popover on iPad seems to block the presentation of the modal VC.
        DispatchQueue.main.async {
            delegate.present(controller, animated: true, completion: nil)
        }

        // Without this rootView.onDismiss, Neeva menu sheet would not hide
        // and settings panel will display on top of it. When user close settings
        // panel, they will still see the Neeva menu sheet open
        self.rootView.onDismiss()
    }

    private func feedbackHandler(_ delegate: BrowserViewController, _ feedbackImage: UIImage?) {
        ClientLogger.shared.logCounter(
            .OpenSendFeedback, attributes: EnvironmentHelper.shared.getAttributes())
        TourManager.shared.userReachedStep(tapTarget: .feedbackMenu)

        // Without this rootView.onDismiss, Neeva menu sheet would not hide
        // and feedback panel will display on top of it. When user close feedback
        // panel, they will still see the Neeva menu sheet open
        self.rootView.onDismiss()

        DispatchQueue.main.asyncAfter(deadline: TourManager.shared.delay()) {
            showFeedbackPanel(bvc: delegate, screenshot: feedbackImage)
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // By default, a UIHostingController opens as an opaque layer, so we override
        // that behavior here.
        view.backgroundColor = .clear
    }
}
