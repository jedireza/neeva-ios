// Copyright Neeva. All rights reserved.

import Defaults
import Foundation

/// Usage: add a `case` to this enum, then reference `FeatureFlag[.myFeature]` to check for that feature’s status.
public enum FeatureFlag: String, CaseIterable, RawRepresentable {
    // IMPORTANT: when adding a new feature flag, make sure to keep this list
    // in alphabetical order to reduce merge conflicts.

    case bottomURLBar = "Bottom URL Bar"
    case cardStrip = "Carousel of cards instead of tab strip"
    case createOrSwitchToTab = "Create new tab or open exisiting tab"
    case debugURLBar = "URL Bar Debug Mode"
    case groupsInSwitcher = "TabGroups in Tab Switcher"
    case inlineAccountSettings = "Inline Account Settings"
    case newTrackingProtectionSettings = "New Tracking Protection Settings"
    case notifications = "Notifications"
    case pinToTopSites = "Pin to Top Sites"
    case readingMode = "Enable Reading Mode"
    case recommendedSpaces = "Recommended Spaces"
    case spacify = "Enable button to turn a page into a Space"
    case swipePlusPlus = "Additional forward and back swipe gestures"
    case suggestionLayoutV2 = "Suggestion Layout V2"
    case suggestionLayoutWithHeader = "Suggestion Layout with header"
    case homeAsSuggestedSite = "Home as Suggested Site"

    public init?(caseName: String) {
        for value in FeatureFlag.allCases where "\(value)" == caseName {
            self = value
            return
        }

        return nil
    }
}

extension FeatureFlag {
    public static let defaultsKey = Defaults.Key<Set<String>>(
        "neevaFeatureFlags", default: [], suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)

    public static var enabledFlags: Set<FeatureFlag> = {
        let names = Defaults[Self.defaultsKey]
        let flags = names.compactMap(FeatureFlag.init(rawValue:))
        Defaults[Self.defaultsKey] = Set(flags.map(\.rawValue))
        return Set(flags)
    }()

    public static subscript(flag: FeatureFlag) -> Bool {
        Self.enabledFlags.contains(flag)
    }
}
