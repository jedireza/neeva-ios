/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import Storage

protocol LibraryPanelDelegate: AnyObject {
    func libraryPanelDidRequestToOpenInNewTab(_ url: URL, _ savedTab: SavedTab?, isPrivate: Bool)
    func libraryPanel(didSelectURL url: URL, visitType: VisitType)
    func libraryPanel(didSelectURLString url: String, visitType: VisitType)
}

enum LibraryPanelType: Int {
    case history = 0
    case downloads = 1
}
