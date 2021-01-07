//
//  UserProfileController.swift
//  
//
//  Created by Jed Fox on 1/7/21.
//

import Foundation

class UserProfileController: QueryController<UserInfoQuery, UserProfileController.User> {
    typealias User = UserInfoQuery.Data.User

    public static let shared = UserProfileController()

    public var userId: String? { data?.id }

    override init() {
        super.init()
        self.reload()
    }

    public func reload() {
        self.perform(query: UserInfoQuery())
    }

    override class func processData(_ data: UserInfoQuery.Data) -> User {
        data.user!
    }
}
