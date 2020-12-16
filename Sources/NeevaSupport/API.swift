// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class UserInfoQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query UserInfo {
      user {
        __typename
        profile {
          __typename
          displayName
          email
          pictureURL
        }
      }
    }
    """

  public let operationName: String = "UserInfo"

  public let operationIdentifier: String? = "f2cbd990b89b2f6f34a689d0962c3ee3b2eeaa1e93cca32838bc60255b777c26"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("user", type: .object(User.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(user: User? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "user": user.flatMap { (value: User) -> ResultMap in value.resultMap }])
    }

    /// The logged-in user making the request.
    public var user: User? {
      get {
        return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "user")
      }
    }

    public struct User: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["User"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(profile: Profile) {
        self.init(unsafeResultMap: ["__typename": "User", "profile": profile.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// User's profile/display information.
      public var profile: Profile {
        get {
          return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "profile")
        }
      }

      public struct Profile: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Profile"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
            GraphQLField("email", type: .nonNull(.scalar(String.self))),
            GraphQLField("pictureURL", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(displayName: String, email: String, pictureUrl: String) {
          self.init(unsafeResultMap: ["__typename": "Profile", "displayName": displayName, "email": email, "pictureURL": pictureUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var displayName: String {
          get {
            return resultMap["displayName"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "displayName")
          }
        }

        public var email: String {
          get {
            return resultMap["email"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "email")
          }
        }

        public var pictureUrl: String {
          get {
            return resultMap["pictureURL"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "pictureURL")
          }
        }
      }
    }
  }
}
