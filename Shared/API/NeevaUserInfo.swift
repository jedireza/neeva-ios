// Copyright Neeva. All rights reserved.

import Foundation
import Reachability
import WebKit
import SwiftUI
import Apollo

public class NeevaUserInfo: ObservableObject {

    private let UserInfoKey = "UserInfo"

    private let defaults: UserDefaults

    public static let shared = NeevaUserInfo()

    @Published public private(set) var id: String?
    @Published public private(set) var displayName: String?
    @Published public private(set) var email: String?
    @Published public private(set) var pictureUrl: String?
    @Published public private(set) var pictureData: Data?
    @Published public private(set) var authProvider: SSOProvider?
    @Published public private(set) var isLoading = false

    /// Using optimistic approach, the user is considered `LoggedIn = true` until we receive a login required GraphQL error.
    @Published public private(set) var isUserLoggedIn: Bool = true

    private let reachability = try! Reachability()
    private var connection: Reachability.Connection?

    public init(previewDisplayName displayName: String?, email: String?, pictureUrl: String?, authProvider: SSOProvider?) {
        self.displayName = displayName
        self.email = email
        self.pictureUrl = pictureUrl
        self.authProvider = (authProvider?.rawValue).flatMap(SSOProvider.init(rawValue:))
        defaults = UserDefaults.standard
        isUserLoggedIn = true
        fetchUserPicture()
    }

    public static let previewLoggedOut = NeevaUserInfo(previewLoggedOut: ())
    public static let previewLoading = NeevaUserInfo(previewLoading: ())
    private init(previewLoggedOut: ()) {
        defaults = UserDefaults.standard
        isUserLoggedIn = false
    }
    private init(previewLoading: ()) {
        defaults = UserDefaults.standard
        isLoading = true
    }

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

        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
        UserInfoQuery().fetch { result in
            self.isLoading = false
            switch result {
            case .success(let data):
                if let user = data.user {
                    self.saveUserInfoToDefaults(userInfo: user)
                    self.fetchUserPicture()
                    self.isUserLoggedIn = true
                    NeevaFeatureFlags.update(featureFlags: user.featureFlags)
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
        }})
    }

    public func didLogOut() {
        clearCache()
        isUserLoggedIn = false
        fetch()
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
                let currentToken = self.getLoginCookie()
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

    public func getLoginCookie() -> String? {
        return try? NeevaConstants.keychain.getString(NeevaConstants.loginKeychainKey)
    }

    public func hasLoginCookie() -> Bool{
        let token = getLoginCookie()
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

        self.id = userInfoDict["userId"]
        self.displayName = userInfoDict["userDisplayName"]
        self.email = userInfoDict["userEmail"]
        self.pictureUrl = userInfoDict["userPictureUrl"]
        self.authProvider = userInfoDict["userAuthProvider"].flatMap(SSOProvider.init(rawValue:))
    }

    private func fetchUserPicture() {
        guard let url = URL(string: pictureUrl ?? "") else {
            return
        }

        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching UserPicture: \(String(describing: error?.localizedDescription))")
                return
            }

            // fixes an error caused by updating UI on the background thread
            DispatchQueue.main.async {
                self.pictureData = data
            }
        }

        dataTask.resume()
    }

    private var isDeviceOnline: Bool {
        if let connection = connection, connection != .unavailable {
            return true
        }

        return false
    }

    private func saveUserInfoToDefaults(userInfo: UserInfoQuery.Data.User) -> Void {
        let userInfoDict = [ "userDisplayName": userInfo.profile.displayName, "userEmail": userInfo.profile.email, "userPictureUrl": userInfo.profile.pictureUrl, "userAuthProvider": userInfo.authProvider, "userId": userInfo.id ]
        defaults.set(userInfoDict, forKey: UserInfoKey)

        displayName = userInfo.profile.displayName
        email = userInfo.profile.email
        pictureUrl = userInfo.profile.pictureUrl
        authProvider = userInfo.authProvider.flatMap(SSOProvider.init(rawValue:))
    }

    private func clearUserInfoCache() -> Void {
        displayName = nil
        email = nil
        pictureUrl = nil
        pictureData = nil
        id = nil
        self.reachability.stopNotifier()
    }
}
