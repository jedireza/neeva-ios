// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct NeevaMenuRootView: View {
    @StateObject var overlaySheetModel = OverlaySheetModel()
    let onDismiss: () -> ()
    let isIncognito: Bool
    var embeddedView: NeevaMenuView

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: self.overlaySheetModel, config: config, onDismiss: { self.onDismiss() } ) {
            self.embeddedView
                .environment(\.isIncognito, isIncognito)
                .overlaySheetIsFixedHeight(isFixedHeight: true).padding(.top, 8)
        }
        .onAppear() {
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class NeevaMenuViewController: UIHostingController<NeevaMenuRootView> {
    var delegate: BrowserViewController?

    public init(delegate: BrowserViewController, onDismiss: @escaping () -> (), isPrivate: Bool, feedbackImage: UIImage?){
        super.init(rootView: NeevaMenuRootView(onDismiss: onDismiss, isIncognito: isPrivate, embeddedView: NeevaMenuView(noTopPadding: true, menuAction: nil) ))

        self.delegate = delegate
        delegate.isNeevaMenuSheetOpen = true
        self.view.accessibilityViewIsModal = true
        
        //Build callbacks for each button action
        let embeddedView = NeevaMenuView(noTopPadding: true) { result in
            delegate.isNeevaMenuSheetOpen = false
            switch result {
            case .home:
                self.rootView.onDismiss()
                ClientLogger.shared.logCounter(.OpenHome, attributes: EnvironmentHelper.shared.getAttributes())
                delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.home)
                break
            case .spaces:
                self.spacesHandler(delegate)
                break
            case .settings:
                self.settingsHandler(delegate)
                break
            case .history:
                self.rootView.onDismiss()
                ClientLogger.shared.logCounter(.OpenHistory, attributes: EnvironmentHelper.shared.getAttributes())
                delegate.zeroQueryPanelDidRequestToOpenLibrary(panel: .history)

                break
            case .downloads:
                self.rootView.onDismiss()
                ClientLogger.shared.logCounter(.OpenDownloads, attributes: EnvironmentHelper.shared.getAttributes())
                
                break
            case .feedback:
                self.feedbackHandler(delegate, feedbackImage)
                break
            }
        }
        self.rootView = NeevaMenuRootView(onDismiss: onDismiss, isIncognito: isPrivate, embeddedView: embeddedView)
    }

    private func spacesHandler(_ delegate: BrowserViewController) {
        // Without this rootView.onDismiss, Neeva menu sheet would not hide
        // after navigating to spaces page. User will still see the Neeva
        // menu sheet open
        self.rootView.onDismiss()
        ClientLogger.shared.logCounter(.OpenSpaces, attributes: EnvironmentHelper.shared.getAttributes())

        // if user started a tour, trigger navigation on webui side
        // to prevent page refresh, which will lost the states
        if TourManager.shared.userReachedStep(step: .promptSpaceInNeevaMenu) != .stopAction {
            delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.spaces)
        }
    }

    private func settingsHandler(_ delegate: BrowserViewController) {
        ClientLogger.shared.logCounter(.OpenSetting, attributes: EnvironmentHelper.shared.getAttributes())
        TourManager.shared.userReachedStep(tapTarget: .settingMenu)

        // Without this dismiss, when user click on settings menu, if there is
        // a quest prompt display on top of it, settings panel would not
        // show up
        self.dismiss( animated: true, completion: nil )

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
        ClientLogger.shared.logCounter(.OpenSendFeedback, attributes: EnvironmentHelper.shared.getAttributes())
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

