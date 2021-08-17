// Copyright Neeva. All rights reserved.

import SwiftUI

protocol ToolbarDelegate: AnyObject {
    var performTabToolbarAction: (ToolbarAction) -> Void { get }
    func perform(overflowMenuAction: OverflowMenuAction, targetButtonView: UIView?)
    func tabToolbarTabsMenu() -> UIMenu?
}

struct TabToolbarContent: View {
    let chromeModel: TabChromeModel

    var body: some View {
        TabToolbarView(
            performAction: { action in chromeModel.toolbarDelegate?.performTabToolbarAction(action)
            },
            buildTabsMenu: { chromeModel.toolbarDelegate?.tabToolbarTabsMenu() },
            onNeevaMenu: {
                ClientLogger.shared.logCounter(
                    .OpenNeevaMenu, attributes: EnvironmentHelper.shared.getAttributes())
                SceneDelegate.getBVC().showNeevaMenuSheet()
            }
        )
        .environmentObject(chromeModel)
    }
}

class TabToolbarHost: IncognitoAwareHostingController<TabToolbarContent> {
    init(chromeModel: TabChromeModel, delegate: ToolbarDelegate) {
        super.init {
            TabToolbarContent(chromeModel: chromeModel)
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
