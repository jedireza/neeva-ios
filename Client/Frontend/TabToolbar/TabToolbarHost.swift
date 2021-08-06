// Copyright Neeva. All rights reserved.

import SwiftUI

class TabToolbarHost: IncognitoAwareHostingController<TabToolbarHost.Content> {

    var tabToolbarDelegate: TabToolbarDelegate?
    var tabsButton = TabsButton()
    var addToSpacesButton = ToolbarButton()
    var forwardButton = ToolbarButton()
    var backButton = ToolbarButton()
    var shareButton = ToolbarButton()
    var toolbarNeevaMenuButton = ToolbarButton()
    var actionButtons: [ToolbarButton] = []

    struct Content: View {
        let model: TabToolbarModel
        weak var delegate: TabToolbarDelegate?

        var body: some View {
            TabToolbarView(
                onBack: { [weak delegate] in delegate?.tabToolbarDidPressBack() },
                onForward: { [weak delegate] in delegate?.tabToolbarDidPressForward() },
                onOverflow: { [weak delegate] in delegate?.tabToolbarDidPressOverflow() },
                onLongPressBackForward: { [weak delegate] in
                    delegate?.tabToolbarDidLongPressBackForward()
                },
                onNeevaMenu: {
                    ClientLogger.shared.logCounter(
                        .OpenNeevaMenu, attributes: EnvironmentHelper.shared.getAttributes())
                    BrowserViewController.foregroundBVC().showNeevaMenuSheet()
                },
                onSaveToSpace: { [weak delegate] in delegate?.tabToolbarSpacesMenu() },
                onShowTabs: { [weak delegate] in delegate?.tabToolbarDidPressTabs() },
                tabsMenu: { [weak delegate] in delegate?.tabToolbarTabsMenu() }
            )
            .environmentObject(model)
        }
    }

    init(model: TabToolbarModel, delegate: TabToolbarDelegate) {
        super.init {
            Content(model: model, delegate: delegate)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // HACK: since this view controller does not take up the whole screen, we are unable to disable the keyboard avoidance
        // behavior of SwiftUI. Instead, we remove any keyboard-related observers from the view, which handles the keyboard avoidance behavior.
        // See https://steipete.com/posts/disabling-keyboard-avoidance-in-swiftui-uihostingcontroller/ for reference.
        let view = self.view!
        NotificationCenter.default.removeObserver(
            view, name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(
            view, name: UIApplication.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(
            view, name: UIApplication.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(
            view, name: UIApplication.keyboardDidHideNotification, object: nil)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
