// Copyright Neeva. All rights reserved.

import SwiftUI

protocol ToolbarDelegate: AnyObject {
    var performTabToolbarAction: (ToolbarAction) -> Void { get }
    func perform(overflowMenuAction: OverflowMenuAction, targetButtonView: UIView?)
    func tabToolbarTabsMenu() -> UIMenu?
}

struct TabToolbarContent: View {
    let chromeModel: TabChromeModel
    let showNeevaMenuSheet: () -> Void

    var body: some View {
        TabToolbarView(
            performAction: { action in chromeModel.toolbarDelegate?.performTabToolbarAction(action)
            },
            buildTabsMenu: { chromeModel.toolbarDelegate?.tabToolbarTabsMenu() },
            onNeevaMenu: {
                ClientLogger.shared.logCounter(
                    .OpenNeevaMenu, attributes: EnvironmentHelper.shared.getAttributes())
                showNeevaMenuSheet()
            }
        )
        .environmentObject(chromeModel)
    }
}

class TabToolbarHost: IncognitoAwareHostingController<TabToolbarContent> {
    init(isIncognito: Bool, chromeModel: TabChromeModel, showNeevaMenuSheet: @escaping () -> Void) {
        super.init(isIncognito: isIncognito) {
            TabToolbarContent(chromeModel: chromeModel, showNeevaMenuSheet: showNeevaMenuSheet)
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

        DispatchQueue.main.async { [self] in
            self.view.heightAnchor.constraint(
                equalToConstant: SceneDelegate.getKeyWindow(for: view).safeAreaInsets.bottom
                    + UIConstants.TopToolbarHeightWithToolbarButtonsShowing
            ).isActive = true
        }

        self.view.backgroundColor = .clear
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.setContentHuggingPriority(.required, for: .vertical)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
