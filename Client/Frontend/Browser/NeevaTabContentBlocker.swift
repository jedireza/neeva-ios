/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Shared
import Defaults

extension Defaults.Keys {
    static let contentBlockingStrength = Defaults.Key<BlockingStrength>("profile.prefkey.trackingprotection.strength", default: .basic)
    static let contentBlockingEnabled = Defaults.Key<Bool>("profile.prefkey.trackingprotection.normalbrowsing", default: true)
}

enum BlockingStrength: String, Codable {
    case basic
    case strict
    case neeva

    static let allOptions: [BlockingStrength] = [.basic, .strict]
}

/**
 Neeva-specific implementation of tab content blocking.
 */
class NeevaTabContentBlocker: TabContentBlocker, TabContentScript {
    class func name() -> String {
        return "TrackingProtectionStats"
    }

    var isUserEnabled: Bool? {
        didSet {
            guard let tab = tab as? Tab else { return }
            setupForTab()
            TabEvent.post(.didChangeContentBlocking, for: tab)
            tab.reload()
        }
    }

    override var isEnabled: Bool {
        isUserEnabled ?? Defaults[.contentBlockingEnabled]
    }

    override init(tab: ContentBlockerTab) {
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        let rules = BlocklistFileName.listsForMode(strength: Defaults[.contentBlockingStrength])
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: isEnabled, rules: rules)
    }

    @objc override func notifiedTabSetupRequired() {
        setupForTab()
        if let tab = tab as? Tab {
            TabEvent.post(.didChangeContentBlocking, for: tab)
        }
    }

    override func currentlyEnabledLists() -> [BlocklistFileName] {

        return BlocklistFileName.listsForMode(strength: Defaults[.contentBlockingStrength])
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension NeevaTabContentBlocker {
    static func isTrackingProtectionEnabled() -> Bool {
        Defaults[.contentBlockingEnabled]
    }

    static func toggleTrackingProtectionEnabled() {
        let isEnabled = Defaults[.contentBlockingEnabled]
        if isEnabled {
            ClientLogger.shared.logCounter(.TurnOffBlockTracking, attributes: EnvironmentHelper.shared.getAttributes())
        } else {
            ClientLogger.shared.logCounter(.TurnOnBlockTracking, attributes: EnvironmentHelper.shared.getAttributes())
        }
            
        Defaults[.contentBlockingEnabled] = !isEnabled
        ContentBlocker.shared.prefsChanged()
    }
}
