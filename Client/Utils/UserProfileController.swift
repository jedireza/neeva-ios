// Copyright Neeva. All rights reserved.

import Foundation
import Shared

/// Singleton controllre class that provides information about the current user.
class UserProfileController: QueryController<UserInfoQuery, UserProfileController.User> {
    typealias User = UserInfoQuery.Data.User

    /// Access the shared `UserProfileController` in a view using this syntax:
    /// ```
    /// @ObservedObject var userProfile = UserProfileController.shared
    /// ```
    static let shared = UserProfileController()

    private init() {
        super.init()
    }

    var userId: String? {
        guard case .success(let data) = state else { return nil }
        return data.id
    }

    override func reload() {
        self.perform(query: UserInfoQuery())
    }

    override class func processData(_ data: UserInfoQuery.Data) -> User {
        data.user!
    }
}
