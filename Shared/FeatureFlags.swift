// Copyright Neeva. All rights reserved.

import Foundation
import Defaults

/// Usage: add a `case` to this enum, then reference `FeatureFlag[.myFeature]` to check for that feature’s status.
public enum FeatureFlag: String, CaseIterable, RawRepresentable {
    // IMPORTANT: when adding a new feature flag, make sure to keep this list
    // in alphabetical order to reduce merge conflicts.
    case cardGrid = "New Switcher UI"
    case cardStrip = "Carousel of cards instead of tab strip"
    case bottomURLBar = "Bottom URL Bar"
    case debugURLBar = "URL Bar Debug Mode"
    case feedbackScreenshot = "Attach Screenshot to Feedback"
    case groupsInSwitcher = "TabGroups and Spaces in Switcher UI"
    case iPadTopTabs = "Show tab strip on iPad"
    case inlineAccountSettings = "Inline Account Settings"
    case legacyURLBar = "Legacy URL Bar"
    case newTopBar = "New Top Bar"
    case newTrackingProtectionSettings = "New Tracking Protection Settings"
    case pinToTopSites = "Pin to Top Sites"
    case readingMode = "Enable Reading Mode"
    case swipePlusPlus = "Additional forward and back swipe gestures"
}

extension FeatureFlag {
    public static let defaultsKey = Defaults.Key<Set<String>>("neevaFeatureFlags", default: [], suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)

    fileprivate static let prune: Void = {
        let names = Defaults[Self.defaultsKey]
        let flags = names.compactMap(FeatureFlag.init(rawValue:))
        Defaults[Self.defaultsKey] = Set(flags.map(\.rawValue))
    }()

    public static subscript(flag: FeatureFlag) -> Bool {
        get {
            Self.prune
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return true
            }
            return Defaults[Self.defaultsKey].contains(flag.rawValue)
        }
        set {
            if newValue {
                Defaults[Self.defaultsKey].insert(flag.rawValue)
            } else {
                Defaults[Self.defaultsKey].remove(flag.rawValue)
            }
        }
    }
}
