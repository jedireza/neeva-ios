/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public enum PushConfigurationLabel: String {
    case neevaDev = "Neeva Dev"
    case neevaNightlyEnterprise = "NeevaNightly"
    case neeva = "Neeva"

    public func toConfiguration() -> PushConfiguration {
        switch self {
        case .neevaDev: return NeevaDevPushConfiguration()
        case .neevaNightlyEnterprise: return NeevaNightlyEnterprisePushConfiguration()
        case .neeva: return NeevaPushConfiguration()
        }
    }
}

public protocol PushConfiguration {
    var label: PushConfigurationLabel { get }

    /// The associated autopush server should speak the protocol documented at
    /// http://autopush.readthedocs.io/en/latest/http.html#push-service-http-api
    /// /v1/{type}/{app_id}
    /// type == apns
    /// app_id == the “platform” or “channel” of development (e.g. “neeva”, “beta”, “gecko”, etc.)
    var endpointURL: NSURL { get }
}

public struct NeevaDevPushConfiguration: PushConfiguration {
    public init() {}
    public let label = PushConfigurationLabel.neevaDev
    public let endpointURL = NSURL(string: "https://updates.push.services.mozilla.com/v1/apns/fennec")!
}

public struct NeevaNightlyEnterprisePushConfiguration: PushConfiguration {
    public init() {}
    public let label = PushConfigurationLabel.neevaNightlyEnterprise
    public let endpointURL = NSURL(string: "https://updates.push.services.mozilla.com/v1/apns/neevanightlyenterprise")!
}

public struct NeevaPushConfiguration: PushConfiguration {
    public init() {}
    public let label = PushConfigurationLabel.neeva
    public let endpointURL = NSURL(string: "https://updates.push.services.mozilla.com/v1/apns/neeva")!
}

