// Copyright Neeva. All rights reserved.

import Apollo
import Foundation
import Reachability
import SwiftUI
import WebKit

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

    public init(
        previewDisplayName displayName: String?, email: String?, pictureUrl: String?,
        authProvider: SSOProvider?
    ) {
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserInfoProvider.shared.fetch { result in
                self.isLoading = false
                switch result {
                case .success(let userInfo):
                    self.saveUserInfoToDefaults(userInfo: userInfo)
                    self.fetchUserPicture()
                    self.isUserLoggedIn = true
                    NeevaFeatureFlags.update(featureFlags: userInfo.featureFlags)
                    UserFlagStore.shared.onUpdateUserFlags(userInfo.userFlags)
                    /// Once we've fetched UserInfo sucessfully, we don't need to keep monitoring connectivity anymore.
                    self.reachability.stopNotifier()
                case .failureAuthenticationError:
                    self.isUserLoggedIn = false
                    self.clearUserInfoCache()
                    self.loadUserInfoFromDefaults()
                case .failureTemporaryError:
                    self.loadUserInfoFromDefaults()
                }
            }
        }
    }

    public func didLogOut() {
        clearCache()
        isUserLoggedIn = false
        fetch()
    }

    public func clearCache() {
        self.clearUserInfoCache()
    }

    public func updateLoginCookieFromWebKitCookieStore(completion: @escaping () -> Void) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            if let authCookie = cookies.first(where: Self.matchesLoginCookie) {
                self.setLoginCookie(authCookie.value)
                completion()
            }
        }
    }

    public func setLoginCookie(_ value: String) {
        // check if token has changed, when different, save new token
        // and fetch user info
        if self.getLoginCookie() == value {
            self.isUserLoggedIn = true
            self.loadUserInfoFromDefaults()
            self.fetchUserPicture()
            self.reachability.stopNotifier()
        } else {
            try? NeevaConstants.keychain.set(value, key: NeevaConstants.loginKeychainKey)
            self.fetch()
        }
    }

    public func getLoginCookie() -> String? {
        return try? NeevaConstants.keychain.getString(NeevaConstants.loginKeychainKey)
    }

    public func hasLoginCookie() -> Bool {
        let token = getLoginCookie()
        if token != nil {
            return true
        }
        return false
    }

    public func deleteLoginCookie() {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            if let authCookie = cookies.first(where: Self.matchesLoginCookie) {
                cookieStore.delete(authCookie)
            }
        }
        try? NeevaConstants.keychain.remove(NeevaConstants.loginKeychainKey)
    }

    private static func matchesLoginCookie(cookie: HTTPCookie) -> Bool {
        // Allow non-HTTPS for testing purposes.
        NeevaConstants.isAppHost(cookie.domain) && cookie.name == "httpd~login"
            && (NeevaConstants.appURL.scheme != "https" || cookie.isSecure)
    }

    public func loadUserInfoFromDefaults() {
        let userInfoDict =
            defaults.object(forKey: UserInfoKey) as? [String: String] ?? [String: String]()

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
                print(
                    "Error fetching UserPicture: \(String(describing: error?.localizedDescription))"
                )
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

    private func saveUserInfoToDefaults(userInfo: UserInfo) {
        let userInfoDict = [
            "userId": userInfo.id,
            "userDisplayName": userInfo.name,
            "userEmail": userInfo.email,
            "userPictureUrl": userInfo.pictureUrl,
            "userAuthProvider": userInfo.authProvider,
        ]
        defaults.set(userInfoDict, forKey: UserInfoKey)

        displayName = userInfo.name
        email = userInfo.email
        pictureUrl = userInfo.pictureUrl
        authProvider = userInfo.authProvider.flatMap(SSOProvider.init(rawValue:))
    }

    private func clearUserInfoCache() {
        displayName = nil
        email = nil
        pictureUrl = nil
        pictureData = nil
        id = nil
        self.reachability.stopNotifier()
    }
}
