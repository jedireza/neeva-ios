// Copyright Neeva. All rights reserved.

import SwiftUI

protocol ToolbarDelegate: AnyObject {
    var performTabToolbarAction: (ToolbarAction) -> Void { get }
    func perform(overflowMenuAction: OverflowMenuAction, targetButtonView: UIView?)
    func tabToolbarTabsMenu() -> UIMenu?
}

class TabToolbarHost: IncognitoAwareHostingController<TabToolbarHost.Content> {

    struct Content: View {
        let chromeModel: TabChromeModel
        let performAction: (ToolbarAction) -> Void
        let buildTabsMenu: () -> UIMenu?

        var body: some View {
            TabToolbarView(
                performAction: performAction,
                buildTabsMenu: buildTabsMenu,
                onNeevaMenu: {
                    ClientLogger.shared.logCounter(
                        .OpenNeevaMenu, attributes: EnvironmentHelper.shared.getAttributes())
                    SceneDelegate.getBVC().showNeevaMenuSheet()
                }
            )
            .environmentObject(chromeModel)
        }
    }

    init(chromeModel: TabChromeModel, delegate: ToolbarDelegate) {
        let performAction = delegate.performTabToolbarAction
        super.init { [weak delegate] in
            Content(
                chromeModel: chromeModel, performAction: performAction,
                buildTabsMenu: { delegate?.tabToolbarTabsMenu() })
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
