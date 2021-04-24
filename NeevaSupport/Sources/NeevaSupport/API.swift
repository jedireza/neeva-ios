// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// Data sent back from client representing user feedback response (V2)
public struct SendFeedbackV2Input: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - feedback
  ///   - shareResults
  ///   - requestId
  ///   - geoLocationStatus
  ///   - source
  ///   - inviteToken
  public init(feedback: Swift.Optional<String?> = nil, shareResults: Swift.Optional<Bool?> = nil, requestId: Swift.Optional<String?> = nil, geoLocationStatus: Swift.Optional<String?> = nil, source: Swift.Optional<FeedbackSource?> = nil, inviteToken: Swift.Optional<String?> = nil) {
    graphQLMap = ["feedback": feedback, "shareResults": shareResults, "requestID": requestId, "geoLocationStatus": geoLocationStatus, "source": source, "inviteToken": inviteToken]
  }

  public var feedback: Swift.Optional<String?> {
    get {
      return graphQLMap["feedback"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "feedback")
    }
  }

  public var shareResults: Swift.Optional<Bool?> {
    get {
      return graphQLMap["shareResults"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "shareResults")
    }
  }

  public var requestId: Swift.Optional<String?> {
    get {
      return graphQLMap["requestID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestID")
    }
  }

  public var geoLocationStatus: Swift.Optional<String?> {
    get {
      return graphQLMap["geoLocationStatus"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "geoLocationStatus")
    }
  }

  public var source: Swift.Optional<FeedbackSource?> {
    get {
      return graphQLMap["source"] as? Swift.Optional<FeedbackSource?> ?? Swift.Optional<FeedbackSource?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "source")
    }
  }

  public var inviteToken: Swift.Optional<String?> {
    get {
      return graphQLMap["inviteToken"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "inviteToken")
    }
  }
}

/// Context in which user provided the feedback
public enum FeedbackSource: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case app
  case extensionUninstall
  case appRegistration
  case appOnboarding
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "App": self = .app
      case "ExtensionUninstall": self = .extensionUninstall
      case "AppRegistration": self = .appRegistration
      case "AppOnboarding": self = .appOnboarding
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .app: return "App"
      case .extensionUninstall: return "ExtensionUninstall"
      case .appRegistration: return "AppRegistration"
      case .appOnboarding: return "AppOnboarding"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: FeedbackSource, rhs: FeedbackSource) -> Bool {
    switch (lhs, rhs) {
      case (.app, .app): return true
      case (.extensionUninstall, .extensionUninstall): return true
      case (.appRegistration, .appRegistration): return true
      case (.appOnboarding, .appOnboarding): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [FeedbackSource] {
    return [
      .app,
      .extensionUninstall,
      .appRegistration,
      .appOnboarding,
    ]
  }
}

public enum ListSpacesKind: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case all
  case visited
  case invited
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "All": self = .all
      case "Visited": self = .visited
      case "Invited": self = .invited
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .all: return "All"
      case .visited: return "Visited"
      case .invited: return "Invited"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ListSpacesKind, rhs: ListSpacesKind) -> Bool {
    switch (lhs, rhs) {
      case (.all, .all): return true
      case (.visited, .visited): return true
      case (.invited, .invited): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ListSpacesKind] {
    return [
      .all,
      .visited,
      .invited,
    ]
  }
}

public struct AddSpaceResultByURLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - url
  ///   - title
  ///   - comment
  ///   - data: Raw data for page being added. Could be HTML from DOM or byte stream if PDF etc
  ///   - mediaType: Type of content, eg text/html
  ///   - contentType: Type of the content obtained from the http response
  ///   - isBase64: Defaults to false
  ///   - snapshot: Details of captured snapshot
  ///   - snapshotExpected: True if we expect a snapshot to be attached to this result soon.
  ///   - snapshotClientError: Error from the client (e.g. extension, iOS app) creating the snapshot.
  public init(spaceId: String, url: String, title: String, comment: Swift.Optional<String?> = nil, data: Swift.Optional<String?> = nil, mediaType: Swift.Optional<String?> = nil, contentType: Swift.Optional<String?> = nil, isBase64: Swift.Optional<Bool?> = nil, snapshot: Swift.Optional<Snapshot?> = nil, snapshotExpected: Swift.Optional<Bool?> = nil, snapshotClientError: Swift.Optional<String?> = nil) {
    graphQLMap = ["spaceID": spaceId, "url": url, "title": title, "comment": comment, "data": data, "mediaType": mediaType, "contentType": contentType, "isBase64": isBase64, "snapshot": snapshot, "snapshotExpected": snapshotExpected, "snapshotClientError": snapshotClientError]
  }

  public var spaceId: String {
    get {
      return graphQLMap["spaceID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var url: String {
    get {
      return graphQLMap["url"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "url")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var comment: Swift.Optional<String?> {
    get {
      return graphQLMap["comment"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "comment")
    }
  }

  /// Raw data for page being added. Could be HTML from DOM or byte stream if PDF etc
  public var data: Swift.Optional<String?> {
    get {
      return graphQLMap["data"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "data")
    }
  }

  /// Type of content, eg text/html
  public var mediaType: Swift.Optional<String?> {
    get {
      return graphQLMap["mediaType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mediaType")
    }
  }

  /// Type of the content obtained from the http response
  public var contentType: Swift.Optional<String?> {
    get {
      return graphQLMap["contentType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contentType")
    }
  }

  /// Defaults to false
  public var isBase64: Swift.Optional<Bool?> {
    get {
      return graphQLMap["isBase64"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isBase64")
    }
  }

  /// Details of captured snapshot
  public var snapshot: Swift.Optional<Snapshot?> {
    get {
      return graphQLMap["snapshot"] as? Swift.Optional<Snapshot?> ?? Swift.Optional<Snapshot?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snapshot")
    }
  }

  /// True if we expect a snapshot to be attached to this result soon.
  public var snapshotExpected: Swift.Optional<Bool?> {
    get {
      return graphQLMap["snapshotExpected"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snapshotExpected")
    }
  }

  /// Error from the client (e.g. extension, iOS app) creating the snapshot.
  public var snapshotClientError: Swift.Optional<String?> {
    get {
      return graphQLMap["snapshotClientError"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snapshotClientError")
    }
  }
}

public struct Snapshot: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - snapshotBase64: snapshot bytes sent as base64 string
  ///   - snapshotContentType
  ///   - htmlSnapshot
  ///   - snapshotBrowser
  ///   - snapshotKind
  public init(snapshotBase64: Swift.Optional<String?> = nil, snapshotContentType: Swift.Optional<String?> = nil, htmlSnapshot: Swift.Optional<String?> = nil, snapshotBrowser: Swift.Optional<String?> = nil, snapshotKind: Swift.Optional<SnapshotKind?> = nil) {
    graphQLMap = ["snapshotBase64": snapshotBase64, "snapshotContentType": snapshotContentType, "htmlSnapshot": htmlSnapshot, "snapshotBrowser": snapshotBrowser, "snapshotKind": snapshotKind]
  }

  /// snapshot bytes sent as base64 string
  public var snapshotBase64: Swift.Optional<String?> {
    get {
      return graphQLMap["snapshotBase64"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snapshotBase64")
    }
  }

  public var snapshotContentType: Swift.Optional<String?> {
    get {
      return graphQLMap["snapshotContentType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snapshotContentType")
    }
  }

  public var htmlSnapshot: Swift.Optional<String?> {
    get {
      return graphQLMap["htmlSnapshot"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "htmlSnapshot")
    }
  }

  public var snapshotBrowser: Swift.Optional<String?> {
    get {
      return graphQLMap["snapshotBrowser"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snapshotBrowser")
    }
  }

  public var snapshotKind: Swift.Optional<SnapshotKind?> {
    get {
      return graphQLMap["snapshotKind"] as? Swift.Optional<SnapshotKind?> ?? Swift.Optional<SnapshotKind?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snapshotKind")
    }
  }
}

public enum SnapshotKind: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unspecified
  case html2Canvas
  case tabCapture
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unspecified": self = .unspecified
      case "Html2Canvas": self = .html2Canvas
      case "TabCapture": self = .tabCapture
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unspecified: return "Unspecified"
      case .html2Canvas: return "Html2Canvas"
      case .tabCapture: return "TabCapture"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SnapshotKind, rhs: SnapshotKind) -> Bool {
    switch (lhs, rhs) {
      case (.unspecified, .unspecified): return true
      case (.html2Canvas, .html2Canvas): return true
      case (.tabCapture, .tabCapture): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SnapshotKind] {
    return [
      .unspecified,
      .html2Canvas,
      .tabCapture,
    ]
  }
}

public enum QuerySuggestionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case standard
  case `operator`
  case searchHistory
  case space
  case unknown
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Standard": self = .standard
      case "Operator": self = .operator
      case "SearchHistory": self = .searchHistory
      case "Space": self = .space
      case "Unknown": self = .unknown
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .standard: return "Standard"
      case .operator: return "Operator"
      case .searchHistory: return "SearchHistory"
      case .space: return "Space"
      case .unknown: return "Unknown"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: QuerySuggestionType, rhs: QuerySuggestionType) -> Bool {
    switch (lhs, rhs) {
      case (.standard, .standard): return true
      case (.operator, .operator): return true
      case (.searchHistory, .searchHistory): return true
      case (.space, .space): return true
      case (.unknown, .unknown): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [QuerySuggestionType] {
    return [
      .standard,
      .operator,
      .searchHistory,
      .space,
      .unknown,
    ]
  }
}

public enum QuerySuggestionSource: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case bing
  case publicNav
  case searchHistory
  case privateCorpus
  case elastic
  case unknown
  case clipboard
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Bing": self = .bing
      case "PublicNav": self = .publicNav
      case "SearchHistory": self = .searchHistory
      case "PrivateCorpus": self = .privateCorpus
      case "Elastic": self = .elastic
      case "Unknown": self = .unknown
      case "Clipboard": self = .clipboard
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .bing: return "Bing"
      case .publicNav: return "PublicNav"
      case .searchHistory: return "SearchHistory"
      case .privateCorpus: return "PrivateCorpus"
      case .elastic: return "Elastic"
      case .unknown: return "Unknown"
      case .clipboard: return "Clipboard"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: QuerySuggestionSource, rhs: QuerySuggestionSource) -> Bool {
    switch (lhs, rhs) {
      case (.bing, .bing): return true
      case (.publicNav, .publicNav): return true
      case (.searchHistory, .searchHistory): return true
      case (.privateCorpus, .privateCorpus): return true
      case (.elastic, .elastic): return true
      case (.unknown, .unknown): return true
      case (.clipboard, .clipboard): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [QuerySuggestionSource] {
    return [
      .bing,
      .publicNav,
      .searchHistory,
      .privateCorpus,
      .elastic,
      .unknown,
      .clipboard,
    ]
  }
}

public enum SpaceACLLevel: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case owner
  case edit
  case comment
  case view
  case publicView
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Owner": self = .owner
      case "Edit": self = .edit
      case "Comment": self = .comment
      case "View": self = .view
      case "PublicView": self = .publicView
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .owner: return "Owner"
      case .edit: return "Edit"
      case .comment: return "Comment"
      case .view: return "View"
      case .publicView: return "PublicView"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SpaceACLLevel, rhs: SpaceACLLevel) -> Bool {
    switch (lhs, rhs) {
      case (.owner, .owner): return true
      case (.edit, .edit): return true
      case (.comment, .comment): return true
      case (.view, .view): return true
      case (.publicView, .publicView): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SpaceACLLevel] {
    return [
      .owner,
      .edit,
      .comment,
      .view,
      .publicView,
    ]
  }
}

public final class UserInfoQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query UserInfo {
      user {
        __typename
        id
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

  public let operationIdentifier: String? = "a4bade7248b9bdcffc766375d2a6ba93551728d2e2a273104476816119a05dd8"

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
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, profile: Profile) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "profile": profile.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// User's Neeva ID.
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
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

public final class SendFeedbackMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SendFeedback($input: SendFeedbackV2Input!) {
      sendFeedbackV2(input: $input)
    }
    """

  public let operationName: String = "SendFeedback"

  public let operationIdentifier: String? = "dc843ee8dfc6f5fc8ba43bba8cf907e6fcd24fe785b37a9be97a8cde14512eb1"

  public var input: SendFeedbackV2Input

  public init(input: SendFeedbackV2Input) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("sendFeedbackV2", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sendFeedbackV2: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sendFeedbackV2": sendFeedbackV2])
    }

    /// Save a free form feedback from user (v2)
    public var sendFeedbackV2: Bool? {
      get {
        return resultMap["sendFeedbackV2"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "sendFeedbackV2")
      }
    }
  }
}

public final class StartIncognitoMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation StartIncognito($redirect: String!) {
      startIncognito(input: {redirect: $redirect})
    }
    """

  public let operationName: String = "StartIncognito"

  public let operationIdentifier: String? = "c56f3d8704d94836640f41e28c4cde4140c3ac7c32e9994e0fcc2c12ec4e98dd"

  public var redirect: String

  public init(redirect: String) {
    self.redirect = redirect
  }

  public var variables: GraphQLMap? {
    return ["redirect": redirect]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("startIncognito", arguments: ["input": ["redirect": GraphQLVariable("redirect")]], type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(startIncognito: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "startIncognito": startIncognito])
    }

    /// Initialize an incognito access token for this user.
    public var startIncognito: String {
      get {
        return resultMap["startIncognito"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "startIncognito")
      }
    }
  }
}

public final class ListSpacesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ListSpaces($kind: ListSpacesKind = All) {
      listSpaces(input: {kind: $kind}) {
        __typename
        requestID
        space {
          __typename
          pageMetadata {
            __typename
            pageID
          }
          space {
            __typename
            ...spaceMetadata
          }
        }
      }
    }
    """

  public let operationName: String = "ListSpaces"

  public let operationIdentifier: String? = "b58a70eef4d167f68d83d584d1115bd2662774ba94137a874ef5fdba882024dd"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + SpaceMetadata.fragmentDefinition)
    return document
  }

  public var kind: ListSpacesKind?

  public init(kind: ListSpacesKind? = nil) {
    self.kind = kind
  }

  public var variables: GraphQLMap? {
    return ["kind": kind]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("listSpaces", arguments: ["input": ["kind": GraphQLVariable("kind")]], type: .object(ListSpace.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(listSpaces: ListSpace? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "listSpaces": listSpaces.flatMap { (value: ListSpace) -> ResultMap in value.resultMap }])
    }

    /// List spaces accessible to the user of the given kind.
    /// Entites and comments are elided from the returned space list.
    public var listSpaces: ListSpace? {
      get {
        return (resultMap["listSpaces"] as? ResultMap).flatMap { ListSpace(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "listSpaces")
      }
    }

    public struct ListSpace: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SpaceList"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("requestID", type: .nonNull(.scalar(String.self))),
          GraphQLField("space", type: .nonNull(.list(.nonNull(.object(Space.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(requestId: String, space: [Space]) {
        self.init(unsafeResultMap: ["__typename": "SpaceList", "requestID": requestId, "space": space.map { (value: Space) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var requestId: String {
        get {
          return resultMap["requestID"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "requestID")
        }
      }

      public var space: [Space] {
        get {
          return (resultMap["space"] as! [ResultMap]).map { (value: ResultMap) -> Space in Space(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Space) -> ResultMap in value.resultMap }, forKey: "space")
        }
      }

      public struct Space: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Space"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("pageMetadata", type: .object(PageMetadatum.selections)),
            GraphQLField("space", type: .object(Space.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(pageMetadata: PageMetadatum? = nil, space: Space? = nil) {
          self.init(unsafeResultMap: ["__typename": "Space", "pageMetadata": pageMetadata.flatMap { (value: PageMetadatum) -> ResultMap in value.resultMap }, "space": space.flatMap { (value: Space) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var pageMetadata: PageMetadatum? {
          get {
            return (resultMap["pageMetadata"] as? ResultMap).flatMap { PageMetadatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "pageMetadata")
          }
        }

        public var space: Space? {
          get {
            return (resultMap["space"] as? ResultMap).flatMap { Space(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "space")
          }
        }

        public struct PageMetadatum: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PageMetadata"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pageID", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(pageId: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PageMetadata", "pageID": pageId])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// An optional identifier for the page.
          public var pageId: String? {
            get {
              return resultMap["pageID"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "pageID")
            }
          }
        }

        public struct Space: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SpaceData"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("userACL", type: .object(UserAcl.selections)),
              GraphQLField("hasPublicACL", type: .scalar(Bool.self)),
              GraphQLField("thumbnail", type: .scalar(String.self)),
              GraphQLField("thumbnailSize", type: .object(ThumbnailSize.selections)),
              GraphQLField("resultCount", type: .scalar(Int.self)),
              GraphQLField("isDefaultSpace", type: .scalar(Bool.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil, userAcl: UserAcl? = nil, hasPublicAcl: Bool? = nil, thumbnail: String? = nil, thumbnailSize: ThumbnailSize? = nil, resultCount: Int? = nil, isDefaultSpace: Bool? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "userACL": userAcl.flatMap { (value: UserAcl) -> ResultMap in value.resultMap }, "hasPublicACL": hasPublicAcl, "thumbnail": thumbnail, "thumbnailSize": thumbnailSize.flatMap { (value: ThumbnailSize) -> ResultMap in value.resultMap }, "resultCount": resultCount, "isDefaultSpace": isDefaultSpace])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var userAcl: UserAcl? {
            get {
              return (resultMap["userACL"] as? ResultMap).flatMap { UserAcl(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "userACL")
            }
          }

          public var hasPublicAcl: Bool? {
            get {
              return resultMap["hasPublicACL"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasPublicACL")
            }
          }

          public var thumbnail: String? {
            get {
              return resultMap["thumbnail"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "thumbnail")
            }
          }

          public var thumbnailSize: ThumbnailSize? {
            get {
              return (resultMap["thumbnailSize"] as? ResultMap).flatMap { ThumbnailSize(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "thumbnailSize")
            }
          }

          public var resultCount: Int? {
            get {
              return resultMap["resultCount"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "resultCount")
            }
          }

          public var isDefaultSpace: Bool? {
            get {
              return resultMap["isDefaultSpace"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "isDefaultSpace")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var spaceMetadata: SpaceMetadata {
              get {
                return SpaceMetadata(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct UserAcl: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceACL"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(acl: SpaceACLLevel) {
              self.init(unsafeResultMap: ["__typename": "SpaceACL", "acl": acl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var acl: SpaceACLLevel {
              get {
                return resultMap["acl"]! as! SpaceACLLevel
              }
              set {
                resultMap.updateValue(newValue, forKey: "acl")
              }
            }
          }

          public struct ThumbnailSize: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["ThumbnailSize"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("height", type: .nonNull(.scalar(Int.self))),
                GraphQLField("width", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(height: Int, width: Int) {
              self.init(unsafeResultMap: ["__typename": "ThumbnailSize", "height": height, "width": width])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var height: Int {
              get {
                return resultMap["height"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "height")
              }
            }

            public var width: Int {
              get {
                return resultMap["width"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "width")
              }
            }
          }
        }
      }
    }
  }
}

public final class AddToSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddToSpace($input: AddSpaceResultByURLInput!) {
      entityId: addSpaceResultByURL(input: $input)
    }
    """

  public let operationName: String = "AddToSpace"

  public let operationIdentifier: String? = "661b239d7f9d0fb8c802fb37f45b25bed49f15d80995582321cb88380ac51653"

  public var input: AddSpaceResultByURLInput

  public init(input: AddSpaceResultByURLInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addSpaceResultByURL", alias: "entityId", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(entityId: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "entityId": entityId])
    }

    /// Add a URL to a space, and return the ID of the space result.
    public var entityId: String {
      get {
        return resultMap["entityId"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "entityId")
      }
    }
  }
}

public final class CreateSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation CreateSpace($name: String!) {
      createSpace(input: {name: $name})
    }
    """

  public let operationName: String = "CreateSpace"

  public let operationIdentifier: String? = "3a1c8dcb01cc11a6109d79f8ef46bd768ec7e6c25d734aef479bf9f994a41c21"

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var variables: GraphQLMap? {
    return ["name": name]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("createSpace", arguments: ["input": ["name": GraphQLVariable("name")]], type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createSpace: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createSpace": createSpace])
    }

    /// API to create a space.
    public var createSpace: String {
      get {
        return resultMap["createSpace"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "createSpace")
      }
    }
  }
}

public final class SuggestionsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Suggestions($query: String!) {
      suggest(q: $query) {
        __typename
        querySuggestion {
          __typename
          suggestedQuery
          type
          boldSpan {
            __typename
            startInclusive
            endExclusive
          }
          source
        }
        urlSuggestion {
          __typename
          icon {
            __typename
            labels
          }
          suggestedURL
          author
          timestamp
          title
          boldSpan {
            __typename
            startInclusive
            endExclusive
          }
        }
      }
    }
    """

  public let operationName: String = "Suggestions"

  public let operationIdentifier: String? = "bbe08089a593b3f103d16e1988bf333ab40539bf1859c82b1598d3f4b2de0b66"

  public var query: String

  public init(query: String) {
    self.query = query
  }

  public var variables: GraphQLMap? {
    return ["query": query]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("suggest", arguments: ["q": GraphQLVariable("query")], type: .object(Suggest.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(suggest: Suggest? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "suggest": suggest.flatMap { (value: Suggest) -> ResultMap in value.resultMap }])
    }

    /// Search suggestions.
    public var suggest: Suggest? {
      get {
        return (resultMap["suggest"] as? ResultMap).flatMap { Suggest(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "suggest")
      }
    }

    public struct Suggest: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Suggest"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("querySuggestion", type: .nonNull(.list(.nonNull(.object(QuerySuggestion.selections))))),
          GraphQLField("urlSuggestion", type: .nonNull(.list(.nonNull(.object(UrlSuggestion.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(querySuggestion: [QuerySuggestion], urlSuggestion: [UrlSuggestion]) {
        self.init(unsafeResultMap: ["__typename": "Suggest", "querySuggestion": querySuggestion.map { (value: QuerySuggestion) -> ResultMap in value.resultMap }, "urlSuggestion": urlSuggestion.map { (value: UrlSuggestion) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// List of suggested queries based on initial query
      public var querySuggestion: [QuerySuggestion] {
        get {
          return (resultMap["querySuggestion"] as! [ResultMap]).map { (value: ResultMap) -> QuerySuggestion in QuerySuggestion(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: QuerySuggestion) -> ResultMap in value.resultMap }, forKey: "querySuggestion")
        }
      }

      /// List of suggested urls based on initial query
      public var urlSuggestion: [UrlSuggestion] {
        get {
          return (resultMap["urlSuggestion"] as! [ResultMap]).map { (value: ResultMap) -> UrlSuggestion in UrlSuggestion(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: UrlSuggestion) -> ResultMap in value.resultMap }, forKey: "urlSuggestion")
        }
      }

      public struct QuerySuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["QuerySuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("suggestedQuery", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(QuerySuggestionType.self))),
            GraphQLField("boldSpan", type: .nonNull(.list(.nonNull(.object(BoldSpan.selections))))),
            GraphQLField("source", type: .nonNull(.scalar(QuerySuggestionSource.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(suggestedQuery: String, type: QuerySuggestionType, boldSpan: [BoldSpan], source: QuerySuggestionSource) {
          self.init(unsafeResultMap: ["__typename": "QuerySuggestion", "suggestedQuery": suggestedQuery, "type": type, "boldSpan": boldSpan.map { (value: BoldSpan) -> ResultMap in value.resultMap }, "source": source])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var suggestedQuery: String {
          get {
            return resultMap["suggestedQuery"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "suggestedQuery")
          }
        }

        public var type: QuerySuggestionType {
          get {
            return resultMap["type"]! as! QuerySuggestionType
          }
          set {
            resultMap.updateValue(newValue, forKey: "type")
          }
        }

        public var boldSpan: [BoldSpan] {
          get {
            return (resultMap["boldSpan"] as! [ResultMap]).map { (value: ResultMap) -> BoldSpan in BoldSpan(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: BoldSpan) -> ResultMap in value.resultMap }, forKey: "boldSpan")
          }
        }

        public var source: QuerySuggestionSource {
          get {
            return resultMap["source"]! as! QuerySuggestionSource
          }
          set {
            resultMap.updateValue(newValue, forKey: "source")
          }
        }

        public struct BoldSpan: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SuggestionBoldSpan"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("startInclusive", type: .nonNull(.scalar(Int.self))),
              GraphQLField("endExclusive", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(startInclusive: Int, endExclusive: Int) {
            self.init(unsafeResultMap: ["__typename": "SuggestionBoldSpan", "startInclusive": startInclusive, "endExclusive": endExclusive])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var startInclusive: Int {
            get {
              return resultMap["startInclusive"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "startInclusive")
            }
          }

          public var endExclusive: Int {
            get {
              return resultMap["endExclusive"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "endExclusive")
            }
          }
        }
      }

      public struct UrlSuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["URLSuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("icon", type: .nonNull(.object(Icon.selections))),
            GraphQLField("suggestedURL", type: .nonNull(.scalar(String.self))),
            GraphQLField("author", type: .scalar(String.self)),
            GraphQLField("timestamp", type: .scalar(String.self)),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("boldSpan", type: .nonNull(.list(.nonNull(.object(BoldSpan.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(icon: Icon, suggestedUrl: String, author: String? = nil, timestamp: String? = nil, title: String? = nil, boldSpan: [BoldSpan]) {
          self.init(unsafeResultMap: ["__typename": "URLSuggestion", "icon": icon.resultMap, "suggestedURL": suggestedUrl, "author": author, "timestamp": timestamp, "title": title, "boldSpan": boldSpan.map { (value: BoldSpan) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var icon: Icon {
          get {
            return Icon(unsafeResultMap: resultMap["icon"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "icon")
          }
        }

        public var suggestedUrl: String {
          get {
            return resultMap["suggestedURL"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "suggestedURL")
          }
        }

        public var author: String? {
          get {
            return resultMap["author"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "author")
          }
        }

        public var timestamp: String? {
          get {
            return resultMap["timestamp"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var title: String? {
          get {
            return resultMap["title"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "title")
          }
        }

        public var boldSpan: [BoldSpan] {
          get {
            return (resultMap["boldSpan"] as! [ResultMap]).map { (value: ResultMap) -> BoldSpan in BoldSpan(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: BoldSpan) -> ResultMap in value.resultMap }, forKey: "boldSpan")
          }
        }

        public struct Icon: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Icon"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("labels", type: .list(.nonNull(.scalar(String.self)))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(labels: [String]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Icon", "labels": labels])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A list of labels to use. The labels are looked up in order, and the
          /// client will use the first found label. If no icons are found matching the
          /// given labels, then it's up to the client to determine whether to
          /// use a default icon or no icon.
          public var labels: [String]? {
            get {
              return resultMap["labels"] as? [String]
            }
            set {
              resultMap.updateValue(newValue, forKey: "labels")
            }
          }
        }

        public struct BoldSpan: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SuggestionBoldSpan"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("startInclusive", type: .nonNull(.scalar(Int.self))),
              GraphQLField("endExclusive", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(startInclusive: Int, endExclusive: Int) {
            self.init(unsafeResultMap: ["__typename": "SuggestionBoldSpan", "startInclusive": startInclusive, "endExclusive": endExclusive])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var startInclusive: Int {
            get {
              return resultMap["startInclusive"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "startInclusive")
            }
          }

          public var endExclusive: Int {
            get {
              return resultMap["endExclusive"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "endExclusive")
            }
          }
        }
      }
    }
  }
}

public struct SpaceMetadata: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment spaceMetadata on SpaceData {
      __typename
      name
      userACL {
        __typename
        acl
      }
      hasPublicACL
      thumbnail
      thumbnailSize {
        __typename
        height
        width
      }
      resultCount
      isDefaultSpace
    }
    """

  public static let possibleTypes: [String] = ["SpaceData"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .scalar(String.self)),
      GraphQLField("userACL", type: .object(UserAcl.selections)),
      GraphQLField("hasPublicACL", type: .scalar(Bool.self)),
      GraphQLField("thumbnail", type: .scalar(String.self)),
      GraphQLField("thumbnailSize", type: .object(ThumbnailSize.selections)),
      GraphQLField("resultCount", type: .scalar(Int.self)),
      GraphQLField("isDefaultSpace", type: .scalar(Bool.self)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(name: String? = nil, userAcl: UserAcl? = nil, hasPublicAcl: Bool? = nil, thumbnail: String? = nil, thumbnailSize: ThumbnailSize? = nil, resultCount: Int? = nil, isDefaultSpace: Bool? = nil) {
    self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "userACL": userAcl.flatMap { (value: UserAcl) -> ResultMap in value.resultMap }, "hasPublicACL": hasPublicAcl, "thumbnail": thumbnail, "thumbnailSize": thumbnailSize.flatMap { (value: ThumbnailSize) -> ResultMap in value.resultMap }, "resultCount": resultCount, "isDefaultSpace": isDefaultSpace])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var name: String? {
    get {
      return resultMap["name"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  public var userAcl: UserAcl? {
    get {
      return (resultMap["userACL"] as? ResultMap).flatMap { UserAcl(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "userACL")
    }
  }

  public var hasPublicAcl: Bool? {
    get {
      return resultMap["hasPublicACL"] as? Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "hasPublicACL")
    }
  }

  public var thumbnail: String? {
    get {
      return resultMap["thumbnail"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "thumbnail")
    }
  }

  public var thumbnailSize: ThumbnailSize? {
    get {
      return (resultMap["thumbnailSize"] as? ResultMap).flatMap { ThumbnailSize(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "thumbnailSize")
    }
  }

  public var resultCount: Int? {
    get {
      return resultMap["resultCount"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "resultCount")
    }
  }

  public var isDefaultSpace: Bool? {
    get {
      return resultMap["isDefaultSpace"] as? Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "isDefaultSpace")
    }
  }

  public struct UserAcl: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["SpaceACL"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(acl: SpaceACLLevel) {
      self.init(unsafeResultMap: ["__typename": "SpaceACL", "acl": acl])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var acl: SpaceACLLevel {
      get {
        return resultMap["acl"]! as! SpaceACLLevel
      }
      set {
        resultMap.updateValue(newValue, forKey: "acl")
      }
    }
  }

  public struct ThumbnailSize: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["ThumbnailSize"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("height", type: .nonNull(.scalar(Int.self))),
        GraphQLField("width", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(height: Int, width: Int) {
      self.init(unsafeResultMap: ["__typename": "ThumbnailSize", "height": height, "width": width])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var height: Int {
      get {
        return resultMap["height"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "height")
      }
    }

    public var width: Int {
      get {
        return resultMap["width"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "width")
      }
    }
  }
}
