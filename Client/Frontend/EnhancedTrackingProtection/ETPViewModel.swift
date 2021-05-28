/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Defaults

class ETPViewModel {
    //  Internal vars
    var etpCoverSheetmodel: ETPCoverSheetModel?
    var startBrowsing: (() -> Void)?
    var goToSettings: (() -> Void)?
    
    // We only show ETP coversheet for specific app updates and not all. The list below is for the version(s)
    // we would like to show the coversheet for.
    static let etpCoverSheetSupportedAppVersion = ["24.0"]
    
    init() {
        setupUpdateModel()
    }

    private func setupUpdateModel() {
        etpCoverSheetmodel = ETPCoverSheetModel(titleImage: #imageLiteral(resourceName: "shield"), titleText: Strings.CoverSheetETPTitle, descriptionText: Strings.CoverSheetETPDescription)
    }
    
    static func shouldShowETPCoverSheet(currentAppVersion: String = VersionSetting.appVersion, isCleanInstall: Bool, supportedAppVersions: [String] = etpCoverSheetSupportedAppVersion) -> Bool {
        // 0,1,2 so we show on 3rd session as a requirement on Github #6012
        let maxSessionCount = 2
        var shouldShow = false
        // Default type is upgrade as in user is upgrading from a different version of the app
        let type = Defaults[.etpCoverSheetShowType] ?? (isCleanInstall ? .CleanInstall : .Upgrade)
        let sessionCount = Defaults[.installSession]
        // Two flows: Coming from clean install or otherwise upgrade flow
        switch type {
        case .CleanInstall:
            // We don't show it but save the 1st clean install session number
            if sessionCount < maxSessionCount {
                // Increment the session number
                Defaults[.installSession] = sessionCount + 1
                Defaults[.etpCoverSheetShowType] = .CleanInstall
            } else if sessionCount == maxSessionCount {
                Defaults[.etpCoverSheetShowType] = .DoNotShow
                shouldShow = true
            }
            break
        case .Upgrade:
            // This will happen if its not a clean install and we are upgrading from another version.
            // This is where we tag it as an upgrade flow and try to present it for specific version(s) Eg. v24.0
            Defaults[.etpCoverSheetShowType] = .Upgrade
            if supportedAppVersions.contains(currentAppVersion) {
                Defaults[.etpCoverSheetShowType] = .DoNotShow
                shouldShow = true
            }
            break
        case .DoNotShow:
            break
        case .Unknown:
            break
        }
        
        return shouldShow
    }
}
