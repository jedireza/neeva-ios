//
//  NeevaUserInfo.swift
//  Client
//
//  Created by BairesDev on 20/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import Foundation
import Reachability
import WebKit
import Apollo

public class NeevaUserInfo {

    private let UserInfoKey = "UserInfo"

    private let defaults: UserDefaults

    public static let shared = NeevaUserInfo()

    private var userId: String?
    private var userDisplayName: String?
    private var userEmail: String?
    private var userPictureUrl: String?
    private var userPictureData: Data?

    /// Using optimistic approach, the user is considered `LoggedIn = true` until we receive a login required GraphQL error.
    public private(set) var isUserLoggedIn: Bool = true

    private let reachability = try! Reachability()
    private var connection: Reachability.Connection?

    private init() {
        self.defaults = UserDefaults.standard

        reachability.whenReachable = { reachability in
            self.connection = reachability.connection
            self.fetch()
        }
        reachability.whenUnreachable = { reachability in
            self.connection = nil
        }
        try! reachability.startNotifier()
    }

    func fetch() {
        if !isDeviceOnline {
            print("Warn: the device is offline, forcing cached information load.")
            self.loadUserInfoFromDefaults()
            return
        }

        UserInfoQuery().fetch { result in
            switch result {
            case .success(let data):
                if let user = data.user {
                    self.saveUserInfoToDefaults(userInfo: user)
                    self.fetchUserPicture()
                    self.isUserLoggedIn = true
                    /// Once we've fetched UserInfo sucessfuly, we don't need to keep monitoring connectivity anymore.
                    self.reachability.stopNotifier()
                }
            case .failure(let error):
                if let errors = (error as? GraphQLAPI.Error)?.errors {
                    let messages = errors.filter({ $0.message != nil }).map({ $0.message! })
                    let errorMsg = "Error fetching UserInfo: \(messages.joined(separator: "\n"))"
                    print(errorMsg)

                    if errorMsg.range(of: "login required", options: .caseInsensitive) != nil {
                        self.isUserLoggedIn = false
                        self.clearUserInfoCache()
                    }
                } else {
                    print("Error fetching UserInfo: \(error)")
                }

                self.loadUserInfoFromDefaults()
            }
        }
    }

    public func clearCache(){
        self.clearUserInfoCache()
    }

    public func updateKeychainTokenAndFetchUserInfo() {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            if let authCookie = cookies.first(where: { NeevaConstants.isAppHost($0.domain) && $0.name == "httpd~login" && $0.isSecure }) {

                // check if token has changed, when different, save new token
                // and fetch user info
                let currentToken = try? NeevaConstants.keychain.getString(NeevaConstants.loginKeychainKey)
                if currentToken != nil, currentToken == authCookie.value {
                    self.isUserLoggedIn = true
                    self.loadUserInfoFromDefaults()
                    self.fetchUserPicture()
                    self.reachability.stopNotifier()
                } else {
                    try? NeevaConstants.keychain.set(authCookie.value, key: NeevaConstants.loginKeychainKey)
                    self.fetch()
                }
            }
        }
    }

    public func hasLoginCookie() -> Bool{
        let token =  try? NeevaConstants.keychain.getString(NeevaConstants.loginKeychainKey)
        if (token != nil) {
           return true
        }
        return false
    }

    public func deleteLoginCookie() {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            if let authCookie = cookies.first(where: { NeevaConstants.isAppHost($0.domain) && $0.name == "httpd~login" && $0.isSecure }) {
                cookieStore.delete(authCookie)
            }
        }
        try? NeevaConstants.keychain.remove(NeevaConstants.loginKeychainKey)
    }

    public func loadUserInfoFromDefaults() -> Void {
        let userInfoDict = defaults.object(forKey: UserInfoKey) as? [String:String] ?? [String:String]()

        userDisplayName = userInfoDict["userDisplayName"]
        userEmail = userInfoDict["userEmail"]
        userPictureUrl = userInfoDict["userPictureUrl"]
        userId = userInfoDict["userId"]
    }

    private func fetchUserPicture() {
        guard let url = URL(string: userPictureUrl ?? "") else {
            return
        }

        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching UserPicture: \(String(describing: error?.localizedDescription))")
                return
            }

            self.userPictureData = data
        }

        dataTask.resume()
    }

    private var isDeviceOnline: Bool {
        if let connection = connection, connection != .unavailable && connection != .none {
            return true
        }

        return false
    }

    public var displayName: String? {
        return userDisplayName
    }

    public var email: String? {
        return userEmail
    }

    public var picture: Data? {
        return userPictureData
    }

    public var id: String? {
        return userId
    }

    private func saveUserInfoToDefaults(userInfo: UserInfoQuery.Data.User) -> Void {
        let userInfoDict = [ "userDisplayName": userInfo.profile.displayName, "userEmail": userInfo.profile.email, "userPictureUrl": userInfo.profile.pictureUrl, "userId": userInfo.id ]
        defaults.set(userInfoDict, forKey: UserInfoKey)

        userDisplayName = userInfo.profile.displayName
        userEmail = userInfo.profile.email
        userPictureUrl = userInfo.profile.pictureUrl
        userId = userInfo.id
    }

    private func clearUserInfoCache() -> Void {
        userDisplayName = nil
        userEmail = nil
        userPictureUrl = nil
        userPictureData = nil
        userId = nil
        self.reachability.stopNotifier()
    }
}
