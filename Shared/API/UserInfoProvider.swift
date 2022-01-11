// Copyright Neeva. All rights reserved.

import Apollo
import Foundation
import SwiftUI

private let log = Logger.browser

/// Information associated with a user account, fetched from the server.
public struct UserInfo {
    let id: String?
    let name: String?
    let email: String?
    let pictureUrl: String?
    let authProvider: String?
    let featureFlags: [UserInfoQuery.Data.User.FeatureFlag]
    let userFlags: [String]
    let subscriptionType: SubscriptionType?

    public init(
        id: String?, name: String?, email: String?, pictureUrl: String?, authProvider: String?,
        featureFlags: [UserInfoQuery.Data.User.FeatureFlag], userFlags: [String],
        subscriptionType: SubscriptionType?
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.pictureUrl = pictureUrl
        self.authProvider = authProvider
        self.featureFlags = featureFlags
        self.userFlags = userFlags
        self.subscriptionType = subscriptionType
    }
}


extension SubscriptionType {
    public var displayName: LocalizedStringKey {
        switch self {
        case .basic: return "Free Basic Membership"
        case .premium: return "Premium Member"
        case .lifetime: return "Lifetime Premium Member"
        case .unknown, .__unknown: return "Unknown"
        }
    }

    public var description: LocalizedStringKey {
        switch self {
        case .basic: return "You are currently part of Neeva’s free basic membership which gives you access to all of Neeva’s search and personalization features (subject to certain usage limits). Neeva will soon offer a premium tier where members can pay a monthly fee and receive unlimited access to all Neeva search and browsing features, plus a range of other benefits. We will notify you when we offer the option to upgrade to Neeva’s premium membership tier."
        case .premium: return "Thank you for subscribing to Neeva Premium."
        case .lifetime: return "As a winner in the referral competition, you are a lifetime premium member of Neeva. You will receive unlimited access to all Neeva search and browsing features, plus a range of other benefits."
        case .unknown, .__unknown: return ""
        }
    }
}

/// Enum container for the result of fetching `UserInfo` from the server.
public enum UserInfoResult {
    /// On success, the `UserInfo` parameter provides information about the user.
    case success(UserInfo)

    /// If unable to fetch user info due to an authentication error.
    case failureAuthenticationError

    /// If unable to fetch user info due to a temporary error (e.g., network
    /// connection issue).
    case failureTemporaryError
}

/// Used to fetch UserInfo from the server. The implementation can be overridden
/// for testing purposes.
open class UserInfoProvider {
    public static var shared = UserInfoProvider()

    public init() {
    }

    open func fetch(completion: @escaping (UserInfoResult) -> Void) {
        UserInfoQuery().fetch { result in
            var userInfoResult: UserInfoResult
            switch result {
            case .success(let data):
                userInfoResult = .success(
                    UserInfo(
                        id: data.user?.id,
                        name: data.user?.profile.displayName,
                        email: data.user?.profile.email,
                        pictureUrl: data.user?.profile.pictureUrl,
                        authProvider: data.user?.authProvider,
                        featureFlags: data.user?.featureFlags ?? [],
                        userFlags: data.user?.flags ?? [],
                        subscriptionType: data.user?.subscriptionType
                    ))
            case .failure(let error):
                userInfoResult = .failureTemporaryError
                if let errors = (error as? GraphQLAPI.Error)?.errors {
                    let messages = errors.filter({ $0.message != nil }).map({ $0.message! })
                    let errorMsg =
                        "Error fetching UserInfo: \(messages.joined(separator: "\n"))"
                    log.error(errorMsg)
                    if errorMsg.range(of: "login required", options: .caseInsensitive) != nil {
                        userInfoResult = .failureAuthenticationError
                    }
                } else {
                    log.error("Error fetching UserInfo: \(error)")
                }
            }
            completion(userInfoResult)
        }
    }
}
