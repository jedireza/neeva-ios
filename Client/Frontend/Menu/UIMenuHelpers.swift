//
//  UIMenuHelpers.swift
//  Client
//
//  Copyright © 2021 Neeva. All rights reserved.
//
import UIKit

extension UIMenu {
    convenience init(options: UIMenu.Options = [], sections: [[UIMenuElement]]) {
        self.init(
            options: options,
            children: sections.map { UIMenu(options: .displayInline, children: $0) }
        )
    }
}

fileprivate let menuActionID = UIAction.Identifier("MenuAction")

extension UIButton {
    func setDynamicMenu(_ builder: @escaping () -> UIMenu?) {
        self.menu = UIMenu(children: [])
        self.addAction(UIAction(identifier: menuActionID) { [weak self] _ in
            if let menu = builder() {
                self?.menu = menu
            } else {
                self?.menu = nil
            }
        }, for: .menuActionTriggered)
    }
    func removeDynamicMenu() {
        self.menu = nil
        self.removeAction(identifiedBy: menuActionID, for: .menuActionTriggered)
    }
}
