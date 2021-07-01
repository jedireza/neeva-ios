/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Storage
import Shared

protocol LibraryPanelContextMenu {
    func getSiteDetails(for indexPath: IndexPath) -> Site?
    func getContextMenuActions(for site: Site, savedTab: SavedTab?, with indexPath: IndexPath) -> [PhotonActionSheetItem]?
    func presentContextMenu(for indexPath: IndexPath, savedTab: SavedTab?)
    func presentContextMenu(for site: Site, with indexPath: IndexPath, completionHandler: @escaping () -> PhotonActionSheet?)
}

extension LibraryPanelContextMenu {
    func presentContextMenu(for indexPath: IndexPath, savedTab: SavedTab?) {
        guard let site = getSiteDetails(for: indexPath) else { return }

        presentContextMenu(for: site, with: indexPath, completionHandler: {
            return self.contextMenu(for: site, savedTab: savedTab, with: indexPath)
        })
    }

    func contextMenu(for site: Site, savedTab: SavedTab?, with indexPath: IndexPath) -> PhotonActionSheet? {
        guard let actions = self.getContextMenuActions(for: site, savedTab: savedTab, with: indexPath) else { return nil }

        let contextMenu = PhotonActionSheet(site: site, actions: actions)
        contextMenu.modalPresentationStyle = .overFullScreen
        contextMenu.modalTransitionStyle = .crossDissolve

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        return contextMenu
    }

    func getDefaultContextMenuActions(for site: Site, savedTab: SavedTab?, libraryPanelDelegate: LibraryPanelDelegate?) -> [PhotonActionSheetItem]? {
        guard let siteURL = URL(string: site.url) else { return nil }

        let openInNewTabAction = PhotonActionSheetItem(title: Strings.OpenInNewTabContextMenuTitle, iconString: "plus.square", iconType: .SystemImage) { _, _ in
            libraryPanelDelegate?.libraryPanelDidRequestToOpenInNewTab(siteURL, savedTab, isPrivate: false)
        }

        let openInNewIncognitoTabAction = PhotonActionSheetItem(title: Strings.OpenInNewIncognitoTabContextMenuTitle, iconString: "incognito") { _, _ in
            libraryPanelDelegate?.libraryPanelDidRequestToOpenInNewTab(siteURL, savedTab, isPrivate: true)
        }

        return [openInNewTabAction, openInNewIncognitoTabAction]
    }
}
