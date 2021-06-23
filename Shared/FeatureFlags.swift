// Copyright Neeva. All rights reserved.

import Foundation
import Defaults

/// Usage: add a `case` to this enum, then reference `FeatureFlag[.myFeature]` to check for that feature’s status.
public enum FeatureFlag: String, CaseIterable, RawRepresentable {
    case inlineAccountSettings = "Inline Account Settings"
    case feedbackScreenshot = "Attach Screenshot to Feedback"
    case pinToTopSites = "Pin to Top Sites"
    case readingMode = "Enable Reading Mode"
    case cardStrip = "Carousel of cards instead of tab strip"
    case swipePlusPlus = "Additional forward and back swipe gestures"
    case newURLBar = "New URL Bar"
    case newURLBarDebug = "New URL Bar: Debug Mode"
    case iPadTopTabs = "Show tab strip on iPad"
    case newToastUI = "Use new Toast interface"
    case welcomeTours = "Navigate to welcome tours web page"
    case newTrackingProtectionSettings = "New Tracking Protection Settings"
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
