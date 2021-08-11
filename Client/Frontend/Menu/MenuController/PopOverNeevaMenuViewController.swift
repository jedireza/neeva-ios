// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

// can’t be fileprivate because the type of the generic on UIHostingController
// is required to be at least as public as the hosting controller subclass itself.
// swift-format-ignore: NoLeadingUnderscores
struct _NeevaMenuPopover: View {
    fileprivate let isIncognito: Bool
    fileprivate let menuAction: (NeevaMenuAction) -> Void

    var body: some View {
        VerticalScrollViewIfNeeded {
            NeevaMenuView(menuAction: menuAction)
                .padding(.bottom, 16)
        }.environment(\.isIncognito, isIncognito)
    }
}

private typealias NeevaMenuPopover = _NeevaMenuPopover

class PopOverNeevaMenuViewController: UIHostingController<_NeevaMenuPopover> {

    var delegate: BrowserViewController?

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(
        delegate: BrowserViewController,
        source: UIView, isPrivate: Bool,
        menuAction: @escaping (NeevaMenuAction) -> Void
    ) {
        super.init(rootView: NeevaMenuPopover(isIncognito: isPrivate, menuAction: { _ in }))
        self.delegate = delegate
        self.modalPresentationStyle = .popover
        self.rootView = NeevaMenuPopover(
            isIncognito: isPrivate,
            menuAction: { [weak self] action in
                self?.dismiss(animated: true) {
                    menuAction(action)
                }
            })

        //Create host as a popup
        let popoverMenuViewController = self.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .up
        popoverMenuViewController?.delegate = delegate
        popoverMenuViewController?.sourceView = source
    }

    override func viewWillAppear(_ animated: Bool) {
        presentationController?.containerView?.subviews.first(where: {
            String(cString: object_getClassName($0)).lowercased().contains("dimming")
        })?.backgroundColor = .ui.backdrop
    }
}
