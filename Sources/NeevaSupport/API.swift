// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

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

public final class SpacesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Spaces {
      listSpaces(input: {kind: All}) {
        __typename
        space {
          __typename
          pageMetadata {
            __typename
            pageID
          }
          space {
            __typename
            name
            description
            resultCount
            isDefaultSpace
            lastModifiedTs
            thumbnail
          }
        }
      }
    }
    """

  public let operationName: String = "Spaces"

  public let operationIdentifier: String? = "e0775f772a8408a440692a94ff5e28ddd37440810ebc8fc15739e5bff19ff16b"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("listSpaces", arguments: ["input": ["kind": "All"]], type: .object(ListSpace.selections)),
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
          GraphQLField("space", type: .nonNull(.list(.nonNull(.object(Space.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(space: [Space]) {
        self.init(unsafeResultMap: ["__typename": "SpaceList", "space": space.map { (value: Space) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
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
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("resultCount", type: .scalar(Int.self)),
              GraphQLField("isDefaultSpace", type: .scalar(Bool.self)),
              GraphQLField("lastModifiedTs", type: .scalar(String.self)),
              GraphQLField("thumbnail", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil, description: String? = nil, resultCount: Int? = nil, isDefaultSpace: Bool? = nil, lastModifiedTs: String? = nil, thumbnail: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "description": description, "resultCount": resultCount, "isDefaultSpace": isDefaultSpace, "lastModifiedTs": lastModifiedTs, "thumbnail": thumbnail])
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

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
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

          public var lastModifiedTs: String? {
            get {
              return resultMap["lastModifiedTs"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "lastModifiedTs")
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
      resultId: addSpaceResultByURL(input: $input)
    }
    """

  public let operationName: String = "AddToSpace"

  public let operationIdentifier: String? = "a8573bf35a374564a0edd2b0154366db42986329eb8dd16d098e3ba0f8be800b"

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
        GraphQLField("addSpaceResultByURL", alias: "resultId", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(resultId: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "resultId": resultId])
    }

    /// Add a URL to a space, and return the ID of the space result.
    public var resultId: String {
      get {
        return resultMap["resultId"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "resultId")
      }
    }
  }
}
