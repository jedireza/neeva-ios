/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Defaults

// Data Model
struct DefaultBrowserOnboardingModel {
    var titleImage: UIImage
    var titleText: String
    var descriptionText: [String]
    var imageText: String
}

class DefaultBrowserOnboardingViewModel {
    //  Internal vars
    var model: DefaultBrowserOnboardingModel?
    var goToSettings: (() -> Void)?
    
    init() {
        setupUpdateModel()
    }

    private func getCorrectImage(for traits: UITraitCollection) -> UIImage {
        let layoutDirection = UIApplication.shared.userInterfaceLayoutDirection
        switch traits.userInterfaceStyle {
        case .dark:
            if layoutDirection == .leftToRight {
                return UIImage(named: "Dark-LTR")!
            } else {
                return UIImage(named: "Dark-RTL")!
            }
        default:
            if layoutDirection == .leftToRight {
                return UIImage(named: "Light-LTR")!
            } else {
                return UIImage(named: "Light-RTL")!
            }
        }
    }
    
    private func setupUpdateModel() {
        model = DefaultBrowserOnboardingModel(titleImage: getCorrectImage(for: UIApplication.shared.keyWindow!.traitCollection), titleText: String.DefaultBrowserCardTitle, descriptionText: [String.DefaultBrowserCardDescription, String.DefaultBrowserOnboardingDescriptionStep1, String.DefaultBrowserOnboardingDescriptionStep2, String.DefaultBrowserOnboardingDescriptionStep3], imageText: String.DefaultBrowserOnboardingScreenshot)
    }
    
    static func shouldShowDefaultBrowserOnboarding() -> Bool {
        // Show on 3rd session
        let maxSessionCount = 3
        var shouldShow = false
        guard !Defaults[.didShowDefaultBrowserOnboarding] else { return false }
        
        if Defaults[.sessionCount] == maxSessionCount {
            shouldShow = true
            Defaults[.didShowDefaultBrowserOnboarding] = true
        }

        return shouldShow
    }
}
