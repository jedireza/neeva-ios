/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Defaults

class UpdateViewModel {
    // Internal vars
    var updateCoverSheetModel: UpdateCoverSheetModel?
    var startBrowsing: (() -> Void)?
    
    // Constants
    let updates: [Update] = [Update(updateImage: #imageLiteral(resourceName: "darkModeUpdate"), updateText: "\(Strings.CoverSheetV22DarkModeTitle)\n\n\(Strings.CoverSheetV22DarkModeDescription)")]
    
    // We only show coversheet for specific app updates and not all. The list below is for the version(s)
    // we would like to show the coversheet for.
    static let coverSheetSupportedAppVersion = ["22.0"]
    
    init() {
        setupUpdateModel()
    }

    private func setupUpdateModel() {
        updateCoverSheetModel = UpdateCoverSheetModel(titleImage: #imageLiteral(resourceName: "splash"), titleText: Strings.WhatsNewString, updates: updates)
    }
    
    static func isCleanInstall() -> Bool {
        // TODO: this is never set?
        if Defaults[.latestAppVersion]?.components(separatedBy: ".").first == nil {
            return true 
        }
        return false
    }
    
    static func shouldShowUpdateSheet(currentAppVersion: String = VersionSetting.appVersion, isCleanInstall: Bool, supportedAppVersions:[String] = []) -> Bool {
        var willShow = false
        if isCleanInstall {
            // We don't show it but save the currentVersion number
            Defaults[.lastVersionNumber] = currentAppVersion
            willShow = false
        } else {
            // Its not a new install so first we check if there is a version number already saved
            if let savedVersion = Defaults[.lastVersionNumber] {
               // Version number saved in user prefs is not the same as current version, return true
               if savedVersion != currentAppVersion {
                Defaults[.lastVersionNumber] = currentAppVersion
                   willShow = true
                 // Version number saved in user prefs matches the current version, return false
               } else if savedVersion == currentAppVersion {
                   willShow = false
               }
            } else {
                // Only way the version is not saved if the user is coming from an app that didn't have this feature
                // as its not a clean install. Hence we should still show the update screen but save the version
                Defaults[.lastVersionNumber] = currentAppVersion
                willShow = true
            }
        }
        // Final version check to only show for specific app versions
        return willShow && supportedAppVersions.contains(currentAppVersion)
    }
}
