// Copyright Neeva. All rights reserved.

import SwiftUI

class TabToolbarHost: IncognitoAwareHostingController<TabToolbarView> {

    var tabToolbarDelegate: TabToolbarDelegate?
    var tabsButton = TabsButton()
    var addToSpacesButton = ToolbarButton()
    var forwardButton = ToolbarButton()
    var backButton = ToolbarButton()
    var shareButton = ToolbarButton()
    var toolbarNeevaMenuButton = ToolbarButton()
    var actionButtons: [ToolbarButton] = []

    init(model: TabToolbarModel, delegate: TabToolbarDelegate) {
        super.init {
            TabToolbarView(
                model: model,
                onBack: { [weak delegate] in delegate?.tabToolbarDidPressBack() },
                onForward: { [weak delegate] in delegate?.tabToolbarDidPressForward() },
                onLongPressBackForward: { [weak delegate] in delegate?.tabToolbarDidLongPressBackForward() },
                onNeevaMenu: { BrowserViewController.foregroundBVC().showNeevaMenuSheet() },
                onSaveToSpace: { [weak delegate] in delegate?.tabToolbarSpacesMenu() },
                onShowTabs: { [weak delegate] in delegate?.tabToolbarDidPressTabs() },
                tabsMenu: { [weak delegate] in delegate?.tabToolbarTabsMenu() }
            )
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
