// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

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

public struct SpaceEmailACL: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - email
  ///   - acl
  public init(email: String, acl: SpaceACLLevel) {
    graphQLMap = ["email": email, "acl": acl]
  }

  public var email: String {
    get {
      return graphQLMap["email"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var acl: SpaceACLLevel {
    get {
      return graphQLMap["acl"] as! SpaceACLLevel
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "acl")
    }
  }
}

/// Data sent back from client representing user feedback response (V2)
public struct SendFeedbackV2Input: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - feedback
  ///   - shareResults
  ///   - requestId
  ///   - geoLocationStatus
  ///   - source
  public init(feedback: Swift.Optional<String?> = nil, shareResults: Swift.Optional<Bool?> = nil, requestId: Swift.Optional<String?> = nil, geoLocationStatus: Swift.Optional<String?> = nil, source: Swift.Optional<FeedbackSource?> = nil) {
    graphQLMap = ["feedback": feedback, "shareResults": shareResults, "requestID": requestId, "geoLocationStatus": geoLocationStatus, "source": source]
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
}

/// Context in which user provided the feedback
public enum FeedbackSource: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case app
  case extensionUninstall
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "App": self = .app
      case "ExtensionUninstall": self = .extensionUninstall
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .app: return "App"
      case .extensionUninstall: return "ExtensionUninstall"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: FeedbackSource, rhs: FeedbackSource) -> Bool {
    switch (lhs, rhs) {
      case (.app, .app): return true
      case (.extensionUninstall, .extensionUninstall): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [FeedbackSource] {
    return [
      .app,
      .extensionUninstall,
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

public struct GetSpaceEntityImagesInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - resultId
  public init(spaceId: Swift.Optional<String?> = nil, resultId: Swift.Optional<String?> = nil) {
    graphQLMap = ["spaceID": spaceId, "resultID": resultId]
  }

  public var spaceId: Swift.Optional<String?> {
    get {
      return graphQLMap["spaceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var resultId: Swift.Optional<String?> {
    get {
      return graphQLMap["resultID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultID")
    }
  }
}

public struct DeleteSpaceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id
  public init(id: String) {
    graphQLMap = ["id": id]
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct UpdateSpaceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id
  ///   - name
  ///   - description
  public init(id: String, name: Swift.Optional<String?> = nil, description: Swift.Optional<String?> = nil) {
    graphQLMap = ["id": id, "name": name, "description": description]
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: Swift.Optional<String?> {
    get {
      return graphQLMap["name"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var description: Swift.Optional<String?> {
    get {
      return graphQLMap["description"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }
}

public struct UpdateSpaceEntityDisplayDataInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - resultId
  ///   - title
  ///   - snippet
  ///   - thumbnail
  public init(spaceId: Swift.Optional<String?> = nil, resultId: Swift.Optional<String?> = nil, title: Swift.Optional<String?> = nil, snippet: Swift.Optional<String?> = nil, thumbnail: Swift.Optional<String?> = nil) {
    graphQLMap = ["spaceID": spaceId, "resultID": resultId, "title": title, "snippet": snippet, "thumbnail": thumbnail]
  }

  public var spaceId: Swift.Optional<String?> {
    get {
      return graphQLMap["spaceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var resultId: Swift.Optional<String?> {
    get {
      return graphQLMap["resultID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultID")
    }
  }

  public var title: Swift.Optional<String?> {
    get {
      return graphQLMap["title"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var snippet: Swift.Optional<String?> {
    get {
      return graphQLMap["snippet"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snippet")
    }
  }

  public var thumbnail: Swift.Optional<String?> {
    get {
      return graphQLMap["thumbnail"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "thumbnail")
    }
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

public enum DefaultSpaceType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unspecified
  case savedForLater
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unspecified": self = .unspecified
      case "SavedForLater": self = .savedForLater
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unspecified: return "Unspecified"
      case .savedForLater: return "SavedForLater"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: DefaultSpaceType, rhs: DefaultSpaceType) -> Bool {
    switch (lhs, rhs) {
      case (.unspecified, .unspecified): return true
      case (.savedForLater, .savedForLater): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [DefaultSpaceType] {
    return [
      .unspecified,
      .savedForLater,
    ]
  }
}

public final class AddSpacePublicAclMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddSpacePublicACL($space: String!) {
      addSpacePublicACL(input: {id: $space})
    }
    """

  public let operationName: String = "AddSpacePublicACL"

  public let operationIdentifier: String? = "2948298e736a49a0b05cb743a28fa031ad5fe9f2c276fc12890b29a2f7ac1c94"

  public var space: String

  public init(space: String) {
    self.space = space
  }

  public var variables: GraphQLMap? {
    return ["space": space]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addSpacePublicACL", arguments: ["input": ["id": GraphQLVariable("space")]], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addSpacePublicAcl: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addSpacePublicACL": addSpacePublicAcl])
    }

    /// Add public ACL to a space.
    public var addSpacePublicAcl: Bool? {
      get {
        return resultMap["addSpacePublicACL"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "addSpacePublicACL")
      }
    }
  }
}

public final class DeleteSpacePublicAclMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteSpacePublicACL($space: String!) {
      deleteSpacePublicACL(input: {id: $space})
    }
    """

  public let operationName: String = "DeleteSpacePublicACL"

  public let operationIdentifier: String? = "21272ebca8e801f17d2f0a853a32ef2e918d84db549c7e817472733c8c73e4fc"

  public var space: String

  public init(space: String) {
    self.space = space
  }

  public var variables: GraphQLMap? {
    return ["space": space]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSpacePublicACL", arguments: ["input": ["id": GraphQLVariable("space")]], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSpacePublicAcl: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSpacePublicACL": deleteSpacePublicAcl])
    }

    /// Delete public ACL from a space.
    public var deleteSpacePublicAcl: Bool? {
      get {
        return resultMap["deleteSpacePublicACL"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteSpacePublicACL")
      }
    }
  }
}

public final class UpdateUserSpaceAclMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateUserSpaceACL($space: String!, $user: String!, $level: SpaceACLLevel!) {
      updateUserSpaceACL(input: {id: $space, userID: $user, acl: $level})
    }
    """

  public let operationName: String = "UpdateUserSpaceACL"

  public let operationIdentifier: String? = "49521db82df9c979d3db75636767ab2aced2eba72c34a0735ebe1d872e6ecc7e"

  public var space: String
  public var user: String
  public var level: SpaceACLLevel

  public init(space: String, user: String, level: SpaceACLLevel) {
    self.space = space
    self.user = user
    self.level = level
  }

  public var variables: GraphQLMap? {
    return ["space": space, "user": user, "level": level]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateUserSpaceACL", arguments: ["input": ["id": GraphQLVariable("space"), "userID": GraphQLVariable("user"), "acl": GraphQLVariable("level")]], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateUserSpaceAcl: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateUserSpaceACL": updateUserSpaceAcl])
    }

    /// Update user ACL on a space.
    public var updateUserSpaceAcl: Bool {
      get {
        return resultMap["updateUserSpaceACL"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "updateUserSpaceACL")
      }
    }
  }
}

public final class DeleteUserSpaceAclMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteUserSpaceACL($space: String!, $user: String!) {
      deleteUserSpaceACL(input: {id: $space, userID: $user})
    }
    """

  public let operationName: String = "DeleteUserSpaceACL"

  public let operationIdentifier: String? = "4d8b1ceafbd19feba6e558cdf4826d8a76615852fba2e671f5c22b2bd018094b"

  public var space: String
  public var user: String

  public init(space: String, user: String) {
    self.space = space
    self.user = user
  }

  public var variables: GraphQLMap? {
    return ["space": space, "user": user]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteUserSpaceACL", arguments: ["input": ["id": GraphQLVariable("space"), "userID": GraphQLVariable("user")]], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteUserSpaceAcl: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteUserSpaceACL": deleteUserSpaceAcl])
    }

    /// Delete user from space.
    public var deleteUserSpaceAcl: Bool {
      get {
        return resultMap["deleteUserSpaceACL"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteUserSpaceACL")
      }
    }
  }
}

public final class AddSpaceSoloAcLsMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddSpaceSoloACLs($space: String!, $shareWith: [SpaceEmailACL!]!, $note: String!) {
      addSpaceSoloACLs(input: {id: $space, shareWith: $shareWith, note: $note}) {
        __typename
        nonNeevanEmails
        changedACLCount
      }
    }
    """

  public let operationName: String = "AddSpaceSoloACLs"

  public let operationIdentifier: String? = "ca7d7669322a15b0ec192148194963d25c8f48840ad6a771b3256b670e6345cf"

  public var space: String
  public var shareWith: [SpaceEmailACL]
  public var note: String

  public init(space: String, shareWith: [SpaceEmailACL], note: String) {
    self.space = space
    self.shareWith = shareWith
    self.note = note
  }

  public var variables: GraphQLMap? {
    return ["space": space, "shareWith": shareWith, "note": note]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addSpaceSoloACLs", arguments: ["input": ["id": GraphQLVariable("space"), "shareWith": GraphQLVariable("shareWith"), "note": GraphQLVariable("note")]], type: .object(AddSpaceSoloAcl.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addSpaceSoloAcLs: AddSpaceSoloAcl? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addSpaceSoloACLs": addSpaceSoloAcLs.flatMap { (value: AddSpaceSoloAcl) -> ResultMap in value.resultMap }])
    }

    /// Add a list of emails to a space.
    public var addSpaceSoloAcLs: AddSpaceSoloAcl? {
      get {
        return (resultMap["addSpaceSoloACLs"] as? ResultMap).flatMap { AddSpaceSoloAcl(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "addSpaceSoloACLs")
      }
    }

    public struct AddSpaceSoloAcl: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AddSpaceSoloACLsResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nonNeevanEmails", type: .list(.nonNull(.scalar(String.self)))),
          GraphQLField("changedACLCount", type: .scalar(Int.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(nonNeevanEmails: [String]? = nil, changedAclCount: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "AddSpaceSoloACLsResponse", "nonNeevanEmails": nonNeevanEmails, "changedACLCount": changedAclCount])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var nonNeevanEmails: [String]? {
        get {
          return resultMap["nonNeevanEmails"] as? [String]
        }
        set {
          resultMap.updateValue(newValue, forKey: "nonNeevanEmails")
        }
      }

      public var changedAclCount: Int? {
        get {
          return resultMap["changedACLCount"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "changedACLCount")
        }
      }
    }
  }
}

public final class ShareSpacePublicLinkMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation ShareSpacePublicLink($space: String!, $emails: [String!]!, $note: String!) {
      shareSpacePublicLink(input: {id: $space, emails: $emails, note: $note}) {
        __typename
        failures
        numShared
      }
    }
    """

  public let operationName: String = "ShareSpacePublicLink"

  public let operationIdentifier: String? = "60e67c776914ceb74366f308d9409746f73a8fb991fb53bde2bc1e7ee1a3535f"

  public var space: String
  public var emails: [String]
  public var note: String

  public init(space: String, emails: [String], note: String) {
    self.space = space
    self.emails = emails
    self.note = note
  }

  public var variables: GraphQLMap? {
    return ["space": space, "emails": emails, "note": note]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("shareSpacePublicLink", arguments: ["input": ["id": GraphQLVariable("space"), "emails": GraphQLVariable("emails"), "note": GraphQLVariable("note")]], type: .object(ShareSpacePublicLink.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(shareSpacePublicLink: ShareSpacePublicLink? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "shareSpacePublicLink": shareSpacePublicLink.flatMap { (value: ShareSpacePublicLink) -> ResultMap in value.resultMap }])
    }

    /// Share space public link via email.
    public var shareSpacePublicLink: ShareSpacePublicLink? {
      get {
        return (resultMap["shareSpacePublicLink"] as? ResultMap).flatMap { ShareSpacePublicLink(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "shareSpacePublicLink")
      }
    }

    public struct ShareSpacePublicLink: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ShareSpacePublicLinkResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("failures", type: .list(.nonNull(.scalar(String.self)))),
          GraphQLField("numShared", type: .scalar(Int.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(failures: [String]? = nil, numShared: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "ShareSpacePublicLinkResponse", "failures": failures, "numShared": numShared])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var failures: [String]? {
        get {
          return resultMap["failures"] as? [String]
        }
        set {
          resultMap.updateValue(newValue, forKey: "failures")
        }
      }

      public var numShared: Int? {
        get {
          return resultMap["numShared"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "numShared")
        }
      }
    }
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

  public let operationIdentifier: String? = "c582b58c174be101bbc88749de01eda491397a237992404aee81af479716631d"

  public var queryDocument: String { return operationDefinition.appending("\n" + SpaceMetadata.fragmentDefinition) }

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
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("createdTs", type: .scalar(String.self)),
              GraphQLField("lastModifiedTs", type: .scalar(String.self)),
              GraphQLField("acl", type: .list(.nonNull(.object(Acl.selections)))),
              GraphQLField("userACL", type: .object(UserAcl.selections)),
              GraphQLField("hasPublicACL", type: .scalar(Bool.self)),
              GraphQLField("comments", type: .list(.nonNull(.object(Comment.selections)))),
              GraphQLField("thumbnail", type: .scalar(String.self)),
              GraphQLField("thumbnailSize", type: .object(ThumbnailSize.selections)),
              GraphQLField("resultCount", type: .scalar(Int.self)),
              GraphQLField("isDefaultSpace", type: .scalar(Bool.self)),
              GraphQLField("defaultSpaceType", type: .scalar(DefaultSpaceType.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil, description: String? = nil, createdTs: String? = nil, lastModifiedTs: String? = nil, acl: [Acl]? = nil, userAcl: UserAcl? = nil, hasPublicAcl: Bool? = nil, comments: [Comment]? = nil, thumbnail: String? = nil, thumbnailSize: ThumbnailSize? = nil, resultCount: Int? = nil, isDefaultSpace: Bool? = nil, defaultSpaceType: DefaultSpaceType? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "description": description, "createdTs": createdTs, "lastModifiedTs": lastModifiedTs, "acl": acl.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, "userACL": userAcl.flatMap { (value: UserAcl) -> ResultMap in value.resultMap }, "hasPublicACL": hasPublicAcl, "comments": comments.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, "thumbnail": thumbnail, "thumbnailSize": thumbnailSize.flatMap { (value: ThumbnailSize) -> ResultMap in value.resultMap }, "resultCount": resultCount, "isDefaultSpace": isDefaultSpace, "defaultSpaceType": defaultSpaceType])
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

          public var createdTs: String? {
            get {
              return resultMap["createdTs"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "createdTs")
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

          public var acl: [Acl]? {
            get {
              return (resultMap["acl"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Acl] in value.map { (value: ResultMap) -> Acl in Acl(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, forKey: "acl")
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

          public var comments: [Comment]? {
            get {
              return (resultMap["comments"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Comment] in value.map { (value: ResultMap) -> Comment in Comment(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, forKey: "comments")
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

          public var defaultSpaceType: DefaultSpaceType? {
            get {
              return resultMap["defaultSpaceType"] as? DefaultSpaceType
            }
            set {
              resultMap.updateValue(newValue, forKey: "defaultSpaceType")
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

          public struct Acl: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceACL"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("userID", type: .nonNull(.scalar(String.self))),
                GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
                GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(userId: String, profile: Profile, acl: SpaceACLLevel) {
              self.init(unsafeResultMap: ["__typename": "SpaceACL", "userID": userId, "profile": profile.resultMap, "acl": acl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var userId: String {
              get {
                return resultMap["userID"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "userID")
              }
            }

            public var profile: Profile {
              get {
                return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "profile")
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

          public struct UserAcl: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceACL"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
                GraphQLField("userID", type: .nonNull(.scalar(String.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(acl: SpaceACLLevel, userId: String) {
              self.init(unsafeResultMap: ["__typename": "SpaceACL", "acl": acl, "userID": userId])
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

            public var userId: String {
              get {
                return resultMap["userID"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "userID")
              }
            }
          }

          public struct Comment: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceCommentData"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .scalar(String.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "SpaceCommentData", "id": id])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: String? {
              get {
                return resultMap["id"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
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

public final class FetchSpaceQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query FetchSpace($id: String!) {
      getSpace(input: {id: $id}) {
        __typename
        requestID
        space {
          __typename
          space {
            __typename
            ...spaceMetadata
            ...spaceComments
            ...spaceContent
          }
        }
      }
    }
    """

  public let operationName: String = "FetchSpace"

  public let operationIdentifier: String? = "6cf038918277e3eb12b154f203d2460a6fc3b0127638dbc20692048bb9d7a993"

  public var queryDocument: String { return operationDefinition.appending("\n" + SpaceMetadata.fragmentDefinition).appending("\n" + SpaceComments.fragmentDefinition).appending("\n" + SpaceContent.fragmentDefinition) }

  public var id: String

  public init(id: String) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getSpace", arguments: ["input": ["id": GraphQLVariable("id")]], type: .object(GetSpace.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getSpace: GetSpace? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getSpace": getSpace.flatMap { (value: GetSpace) -> ResultMap in value.resultMap }])
    }

    /// Get full details for specific space.
    /// This returns a space list in case we support getting multiple spaces in the future.
    public var getSpace: GetSpace? {
      get {
        return (resultMap["getSpace"] as? ResultMap).flatMap { GetSpace(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getSpace")
      }
    }

    public struct GetSpace: GraphQLSelectionSet {
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
            GraphQLField("space", type: .object(Space.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(space: Space? = nil) {
          self.init(unsafeResultMap: ["__typename": "Space", "space": space.flatMap { (value: Space) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
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

        public struct Space: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SpaceData"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("createdTs", type: .scalar(String.self)),
              GraphQLField("lastModifiedTs", type: .scalar(String.self)),
              GraphQLField("acl", type: .list(.nonNull(.object(Acl.selections)))),
              GraphQLField("userACL", type: .object(UserAcl.selections)),
              GraphQLField("hasPublicACL", type: .scalar(Bool.self)),
              GraphQLField("comments", type: .list(.nonNull(.object(Comment.selections)))),
              GraphQLField("thumbnail", type: .scalar(String.self)),
              GraphQLField("thumbnailSize", type: .object(ThumbnailSize.selections)),
              GraphQLField("resultCount", type: .scalar(Int.self)),
              GraphQLField("isDefaultSpace", type: .scalar(Bool.self)),
              GraphQLField("defaultSpaceType", type: .scalar(DefaultSpaceType.self)),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("comments", type: .list(.nonNull(.object(Comment.selections)))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("entities", type: .list(.nonNull(.object(Entity.selections)))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil, description: String? = nil, createdTs: String? = nil, lastModifiedTs: String? = nil, acl: [Acl]? = nil, userAcl: UserAcl? = nil, hasPublicAcl: Bool? = nil, comments: [Comment]? = nil, thumbnail: String? = nil, thumbnailSize: ThumbnailSize? = nil, resultCount: Int? = nil, isDefaultSpace: Bool? = nil, defaultSpaceType: DefaultSpaceType? = nil, entities: [Entity]? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "description": description, "createdTs": createdTs, "lastModifiedTs": lastModifiedTs, "acl": acl.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, "userACL": userAcl.flatMap { (value: UserAcl) -> ResultMap in value.resultMap }, "hasPublicACL": hasPublicAcl, "comments": comments.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, "thumbnail": thumbnail, "thumbnailSize": thumbnailSize.flatMap { (value: ThumbnailSize) -> ResultMap in value.resultMap }, "resultCount": resultCount, "isDefaultSpace": isDefaultSpace, "defaultSpaceType": defaultSpaceType, "entities": entities.flatMap { (value: [Entity]) -> [ResultMap] in value.map { (value: Entity) -> ResultMap in value.resultMap } }])
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

          public var createdTs: String? {
            get {
              return resultMap["createdTs"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "createdTs")
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

          public var acl: [Acl]? {
            get {
              return (resultMap["acl"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Acl] in value.map { (value: ResultMap) -> Acl in Acl(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, forKey: "acl")
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

          public var comments: [Comment]? {
            get {
              return (resultMap["comments"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Comment] in value.map { (value: ResultMap) -> Comment in Comment(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, forKey: "comments")
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

          public var defaultSpaceType: DefaultSpaceType? {
            get {
              return resultMap["defaultSpaceType"] as? DefaultSpaceType
            }
            set {
              resultMap.updateValue(newValue, forKey: "defaultSpaceType")
            }
          }

          public var entities: [Entity]? {
            get {
              return (resultMap["entities"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Entity] in value.map { (value: ResultMap) -> Entity in Entity(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Entity]) -> [ResultMap] in value.map { (value: Entity) -> ResultMap in value.resultMap } }, forKey: "entities")
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

            public var spaceComments: SpaceComments {
              get {
                return SpaceComments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var spaceContent: SpaceContent {
              get {
                return SpaceContent(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Acl: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceACL"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("userID", type: .nonNull(.scalar(String.self))),
                GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
                GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(userId: String, profile: Profile, acl: SpaceACLLevel) {
              self.init(unsafeResultMap: ["__typename": "SpaceACL", "userID": userId, "profile": profile.resultMap, "acl": acl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var userId: String {
              get {
                return resultMap["userID"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "userID")
              }
            }

            public var profile: Profile {
              get {
                return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "profile")
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

          public struct UserAcl: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceACL"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
                GraphQLField("userID", type: .nonNull(.scalar(String.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(acl: SpaceACLLevel, userId: String) {
              self.init(unsafeResultMap: ["__typename": "SpaceACL", "acl": acl, "userID": userId])
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

            public var userId: String {
              get {
                return resultMap["userID"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "userID")
              }
            }
          }

          public struct Comment: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceCommentData"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .scalar(String.self)),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .scalar(String.self)),
                GraphQLField("userid", type: .scalar(String.self)),
                GraphQLField("profile", type: .object(Profile.selections)),
                GraphQLField("createdTs", type: .scalar(String.self)),
                GraphQLField("lastModifiedTs", type: .scalar(String.self)),
                GraphQLField("comment", type: .scalar(String.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: String? = nil, userid: String? = nil, profile: Profile? = nil, createdTs: String? = nil, lastModifiedTs: String? = nil, comment: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "SpaceCommentData", "id": id, "userid": userid, "profile": profile.flatMap { (value: Profile) -> ResultMap in value.resultMap }, "createdTs": createdTs, "lastModifiedTs": lastModifiedTs, "comment": comment])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: String? {
              get {
                return resultMap["id"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var userid: String? {
              get {
                return resultMap["userid"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "userid")
              }
            }

            public var profile: Profile? {
              get {
                return (resultMap["profile"] as? ResultMap).flatMap { Profile(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "profile")
              }
            }

            public var createdTs: String? {
              get {
                return resultMap["createdTs"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "createdTs")
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

            public var comment: String? {
              get {
                return resultMap["comment"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "comment")
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

          public struct Entity: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceEntity"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("metadata", type: .object(Metadatum.selections)),
                GraphQLField("spaceEntity", type: .object(SpaceEntity.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(metadata: Metadatum? = nil, spaceEntity: SpaceEntity? = nil) {
              self.init(unsafeResultMap: ["__typename": "SpaceEntity", "metadata": metadata.flatMap { (value: Metadatum) -> ResultMap in value.resultMap }, "spaceEntity": spaceEntity.flatMap { (value: SpaceEntity) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var metadata: Metadatum? {
              get {
                return (resultMap["metadata"] as? ResultMap).flatMap { Metadatum(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "metadata")
              }
            }

            public var spaceEntity: SpaceEntity? {
              get {
                return (resultMap["spaceEntity"] as? ResultMap).flatMap { SpaceEntity(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "spaceEntity")
              }
            }

            public struct Metadatum: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["ResultMetadata"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("docID", type: .scalar(String.self)),
                  GraphQLField("loggingResultType", type: .scalar(String.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(docId: String? = nil, loggingResultType: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "ResultMetadata", "docID": docId, "loggingResultType": loggingResultType])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// The DocID for this item
              /// See: https://github.com/neevaco/neeva/blob/41e1f138129605b106dc88d456ed50f1b9da4578/docs/doc.go#L18-L26
              public var docId: String? {
                get {
                  return resultMap["docID"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "docID")
                }
              }

              /// LoggingResultType is result type used for logging
              public var loggingResultType: String? {
                get {
                  return resultMap["loggingResultType"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "loggingResultType")
                }
              }
            }

            public struct SpaceEntity: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["SpaceEntityData"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("url", type: .scalar(String.self)),
                  GraphQLField("title", type: .scalar(String.self)),
                  GraphQLField("snippet", type: .scalar(String.self)),
                  GraphQLField("resultType", type: .scalar(String.self)),
                  GraphQLField("contentType", type: .scalar(String.self)),
                  GraphQLField("contentURL", type: .scalar(String.self)),
                  GraphQLField("contentHeight", type: .scalar(Int.self)),
                  GraphQLField("contentWidth", type: .scalar(Int.self)),
                  GraphQLField("thumbnail", type: .scalar(String.self)),
                  GraphQLField("createdBy", type: .object(CreatedBy.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(url: String? = nil, title: String? = nil, snippet: String? = nil, resultType: String? = nil, contentType: String? = nil, contentUrl: String? = nil, contentHeight: Int? = nil, contentWidth: Int? = nil, thumbnail: String? = nil, createdBy: CreatedBy? = nil) {
                self.init(unsafeResultMap: ["__typename": "SpaceEntityData", "url": url, "title": title, "snippet": snippet, "resultType": resultType, "contentType": contentType, "contentURL": contentUrl, "contentHeight": contentHeight, "contentWidth": contentWidth, "thumbnail": thumbnail, "createdBy": createdBy.flatMap { (value: CreatedBy) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var url: String? {
                get {
                  return resultMap["url"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "url")
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

              public var snippet: String? {
                get {
                  return resultMap["snippet"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "snippet")
                }
              }

              public var resultType: String? {
                get {
                  return resultMap["resultType"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "resultType")
                }
              }

              public var contentType: String? {
                get {
                  return resultMap["contentType"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "contentType")
                }
              }

              public var contentUrl: String? {
                get {
                  return resultMap["contentURL"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "contentURL")
                }
              }

              public var contentHeight: Int? {
                get {
                  return resultMap["contentHeight"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "contentHeight")
                }
              }

              public var contentWidth: Int? {
                get {
                  return resultMap["contentWidth"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "contentWidth")
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

              public var createdBy: CreatedBy? {
                get {
                  return (resultMap["createdBy"] as? ResultMap).flatMap { CreatedBy(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "createdBy")
                }
              }

              public struct CreatedBy: GraphQLSelectionSet {
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
      }
    }
  }
}

public final class FetchSpaceResultThumbnailsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query FetchSpaceResultThumbnails($input: GetSpaceEntityImagesInput) {
      getSpaceEntityImages(input: $input) {
        __typename
        images {
          __typename
          imageURL
          thumbnail
        }
      }
    }
    """

  public let operationName: String = "FetchSpaceResultThumbnails"

  public let operationIdentifier: String? = "60c1dd45df0a19383a45b8104958cbc7af7dba9baae8a1428fe5ac019bdb90d1"

  public var input: GetSpaceEntityImagesInput?

  public init(input: GetSpaceEntityImagesInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getSpaceEntityImages", arguments: ["input": GraphQLVariable("input")], type: .object(GetSpaceEntityImage.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getSpaceEntityImages: GetSpaceEntityImage? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getSpaceEntityImages": getSpaceEntityImages.flatMap { (value: GetSpaceEntityImage) -> ResultMap in value.resultMap }])
    }

    /// Get the images corresponding to a space entity. This endpoint returns all of the images for the space entity, unlike
    /// getSpace which only returns a single selected image per entity, and is used to allow the user to choose an image for
    /// the entity.
    public var getSpaceEntityImages: GetSpaceEntityImage? {
      get {
        return (resultMap["getSpaceEntityImages"] as? ResultMap).flatMap { GetSpaceEntityImage(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getSpaceEntityImages")
      }
    }

    public struct GetSpaceEntityImage: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["GetSpaceEntityImagesResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("images", type: .list(.nonNull(.object(Image.selections)))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(images: [Image]? = nil) {
        self.init(unsafeResultMap: ["__typename": "GetSpaceEntityImagesResponse", "images": images.flatMap { (value: [Image]) -> [ResultMap] in value.map { (value: Image) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var images: [Image]? {
        get {
          return (resultMap["images"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Image] in value.map { (value: ResultMap) -> Image in Image(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Image]) -> [ResultMap] in value.map { (value: Image) -> ResultMap in value.resultMap } }, forKey: "images")
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["SpaceEntityImage"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("imageURL", type: .scalar(String.self)),
            GraphQLField("thumbnail", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(imageUrl: String? = nil, thumbnail: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "SpaceEntityImage", "imageURL": imageUrl, "thumbnail": thumbnail])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var imageUrl: String? {
          get {
            return resultMap["imageURL"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "imageURL")
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

public final class DeleteSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteSpace($input: DeleteSpaceInput!) {
      deleteSpace(input: $input)
    }
    """

  public let operationName: String = "DeleteSpace"

  public let operationIdentifier: String? = "d1565076557135baf018125228903ebddedbb2aaac0fb6548027073aca93cf3b"

  public var input: DeleteSpaceInput

  public init(input: DeleteSpaceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSpace", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSpace: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSpace": deleteSpace])
    }

    /// API to delete a space.
    public var deleteSpace: Bool {
      get {
        return resultMap["deleteSpace"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteSpace")
      }
    }
  }
}

public final class UpdateSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateSpace($input: UpdateSpaceInput!) {
      updateSpace(input: $input)
    }
    """

  public let operationName: String = "UpdateSpace"

  public let operationIdentifier: String? = "088045e16c6d36719441ffe31e587aa6062705ebde5b38e12d1e00396ac60e34"

  public var input: UpdateSpaceInput

  public init(input: UpdateSpaceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateSpace", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSpace: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSpace": updateSpace])
    }

    /// API to update a space.
    public var updateSpace: Bool {
      get {
        return resultMap["updateSpace"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "updateSpace")
      }
    }
  }
}

public final class BatchDeleteSpaceResultMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation BatchDeleteSpaceResult($space: String!, $results: [String!]!) {
      batchDeleteSpaceResult(input: {spaceID: $space, resultIDs: $results})
    }
    """

  public let operationName: String = "BatchDeleteSpaceResult"

  public let operationIdentifier: String? = "7226d7296e106dc96c3dddad199364ff60241469091213dfcff3470b217b3d71"

  public var space: String
  public var results: [String]

  public init(space: String, results: [String]) {
    self.space = space
    self.results = results
  }

  public var variables: GraphQLMap? {
    return ["space": space, "results": results]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("batchDeleteSpaceResult", arguments: ["input": ["spaceID": GraphQLVariable("space"), "resultIDs": GraphQLVariable("results")]], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(batchDeleteSpaceResult: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "batchDeleteSpaceResult": batchDeleteSpaceResult])
    }

    /// API to delete entity from a space.
    public var batchDeleteSpaceResult: Bool {
      get {
        return resultMap["batchDeleteSpaceResult"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "batchDeleteSpaceResult")
      }
    }
  }
}

public final class UpdateSpaceResultMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateSpaceResult($input: UpdateSpaceEntityDisplayDataInput!) {
      updateSpaceEntityDisplayData(input: $input)
    }
    """

  public let operationName: String = "UpdateSpaceResult"

  public let operationIdentifier: String? = "9ca18f7364a5c8a60866e1441b07d796d967773f73b062d900221845231d07c5"

  public var input: UpdateSpaceEntityDisplayDataInput

  public init(input: UpdateSpaceEntityDisplayDataInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateSpaceEntityDisplayData", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSpaceEntityDisplayData: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSpaceEntityDisplayData": updateSpaceEntityDisplayData])
    }

    /// API to update the display data for space entities.
    public var updateSpaceEntityDisplayData: Bool? {
      get {
        return resultMap["updateSpaceEntityDisplayData"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "updateSpaceEntityDisplayData")
      }
    }
  }
}

public final class AddSpaceCommentMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddSpaceComment($space: String!, $commentText: String!) {
      addSpaceComment(input: {spaceID: $space, comment: $commentText})
    }
    """

  public let operationName: String = "AddSpaceComment"

  public let operationIdentifier: String? = "ba492b387fdf46832826fe39e8f7d6db4c797a545322a839f1ec7351a2cc10e8"

  public var space: String
  public var commentText: String

  public init(space: String, commentText: String) {
    self.space = space
    self.commentText = commentText
  }

  public var variables: GraphQLMap? {
    return ["space": space, "commentText": commentText]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addSpaceComment", arguments: ["input": ["spaceID": GraphQLVariable("space"), "comment": GraphQLVariable("commentText")]], type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addSpaceComment: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addSpaceComment": addSpaceComment])
    }

    /// API to add a comment to a space.
    public var addSpaceComment: String? {
      get {
        return resultMap["addSpaceComment"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "addSpaceComment")
      }
    }
  }
}

public final class UpdateSpaceCommentMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateSpaceComment($space: String!, $comment: String!, $commentText: String!) {
      updateSpaceComment(
        input: {spaceID: $space, commentID: $comment, comment: $commentText}
      )
    }
    """

  public let operationName: String = "UpdateSpaceComment"

  public let operationIdentifier: String? = "5d57c9fa69ffc2ca603d804e53c586c185369e21ae2af4628beb4a77b844276b"

  public var space: String
  public var comment: String
  public var commentText: String

  public init(space: String, comment: String, commentText: String) {
    self.space = space
    self.comment = comment
    self.commentText = commentText
  }

  public var variables: GraphQLMap? {
    return ["space": space, "comment": comment, "commentText": commentText]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateSpaceComment", arguments: ["input": ["spaceID": GraphQLVariable("space"), "commentID": GraphQLVariable("comment"), "comment": GraphQLVariable("commentText")]], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSpaceComment: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSpaceComment": updateSpaceComment])
    }

    /// API to update a comment on a space.
    public var updateSpaceComment: Bool? {
      get {
        return resultMap["updateSpaceComment"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "updateSpaceComment")
      }
    }
  }
}

public final class DeleteSpaceCommentMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteSpaceComment($space: String!, $comment: String!) {
      deleteSpaceComment(input: {spaceID: $space, commentID: $comment})
    }
    """

  public let operationName: String = "DeleteSpaceComment"

  public let operationIdentifier: String? = "184754a4354cbcfb7d051ecef954c7c3ce96816981c9cbc92e12997c0322abc8"

  public var space: String
  public var comment: String

  public init(space: String, comment: String) {
    self.space = space
    self.comment = comment
  }

  public var variables: GraphQLMap? {
    return ["space": space, "comment": comment]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSpaceComment", arguments: ["input": ["spaceID": GraphQLVariable("space"), "commentID": GraphQLVariable("comment")]], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSpaceComment: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSpaceComment": deleteSpaceComment])
    }

    /// API to delete a comment on a space.
    public var deleteSpaceComment: Bool? {
      get {
        return resultMap["deleteSpaceComment"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteSpaceComment")
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

public final class ContactSuggestionsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ContactSuggestions($query: String!) {
      suggestContacts(q: $query) {
        __typename
        query
        requestID
        contactSuggestions {
          __typename
          profile {
            __typename
            displayName
            email
            pictureURL
          }
        }
      }
    }
    """

  public let operationName: String = "ContactSuggestions"

  public let operationIdentifier: String? = "18ce414a04a63ca8b73d47988dd9a1c1e3343db0b93b9b8f696789884ba0982b"

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
        GraphQLField("suggestContacts", arguments: ["q": GraphQLVariable("query")], type: .object(SuggestContact.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(suggestContacts: SuggestContact? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "suggestContacts": suggestContacts.flatMap { (value: SuggestContact) -> ResultMap in value.resultMap }])
    }

    /// Suggestions for contacts (i.e. people).
    public var suggestContacts: SuggestContact? {
      get {
        return (resultMap["suggestContacts"] as? ResultMap).flatMap { SuggestContact(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "suggestContacts")
      }
    }

    public struct SuggestContact: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SuggestContacts"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("query", type: .scalar(String.self)),
          GraphQLField("requestID", type: .scalar(String.self)),
          GraphQLField("contactSuggestions", type: .list(.nonNull(.object(ContactSuggestion.selections)))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(query: String? = nil, requestId: String? = nil, contactSuggestions: [ContactSuggestion]? = nil) {
        self.init(unsafeResultMap: ["__typename": "SuggestContacts", "query": query, "requestID": requestId, "contactSuggestions": contactSuggestions.flatMap { (value: [ContactSuggestion]) -> [ResultMap] in value.map { (value: ContactSuggestion) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Input to suggest contacts API
      public var query: String? {
        get {
          return resultMap["query"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "query")
        }
      }

      /// requestID for suggest contacts request
      public var requestId: String? {
        get {
          return resultMap["requestID"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "requestID")
        }
      }

      /// List of suggested contacts based on query
      public var contactSuggestions: [ContactSuggestion]? {
        get {
          return (resultMap["contactSuggestions"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [ContactSuggestion] in value.map { (value: ResultMap) -> ContactSuggestion in ContactSuggestion(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [ContactSuggestion]) -> [ResultMap] in value.map { (value: ContactSuggestion) -> ResultMap in value.resultMap } }, forKey: "contactSuggestions")
        }
      }

      public struct ContactSuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ContactSuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("profile", type: .object(Profile.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(profile: Profile? = nil) {
          self.init(unsafeResultMap: ["__typename": "ContactSuggestion", "profile": profile.flatMap { (value: Profile) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var profile: Profile? {
          get {
            return (resultMap["profile"] as? ResultMap).flatMap { Profile(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "profile")
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
}

public struct SpaceMetadata: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment spaceMetadata on SpaceData {
      __typename
      name
      description
      createdTs
      lastModifiedTs
      acl {
        __typename
        userID
        profile {
          __typename
          displayName
          email
          pictureURL
        }
        acl
      }
      userACL {
        __typename
        acl
        userID
      }
      hasPublicACL
      comments {
        __typename
        id
      }
      thumbnail
      thumbnailSize {
        __typename
        height
        width
      }
      resultCount
      isDefaultSpace
      defaultSpaceType
    }
    """

  public static let possibleTypes: [String] = ["SpaceData"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .scalar(String.self)),
      GraphQLField("description", type: .scalar(String.self)),
      GraphQLField("createdTs", type: .scalar(String.self)),
      GraphQLField("lastModifiedTs", type: .scalar(String.self)),
      GraphQLField("acl", type: .list(.nonNull(.object(Acl.selections)))),
      GraphQLField("userACL", type: .object(UserAcl.selections)),
      GraphQLField("hasPublicACL", type: .scalar(Bool.self)),
      GraphQLField("comments", type: .list(.nonNull(.object(Comment.selections)))),
      GraphQLField("thumbnail", type: .scalar(String.self)),
      GraphQLField("thumbnailSize", type: .object(ThumbnailSize.selections)),
      GraphQLField("resultCount", type: .scalar(Int.self)),
      GraphQLField("isDefaultSpace", type: .scalar(Bool.self)),
      GraphQLField("defaultSpaceType", type: .scalar(DefaultSpaceType.self)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(name: String? = nil, description: String? = nil, createdTs: String? = nil, lastModifiedTs: String? = nil, acl: [Acl]? = nil, userAcl: UserAcl? = nil, hasPublicAcl: Bool? = nil, comments: [Comment]? = nil, thumbnail: String? = nil, thumbnailSize: ThumbnailSize? = nil, resultCount: Int? = nil, isDefaultSpace: Bool? = nil, defaultSpaceType: DefaultSpaceType? = nil) {
    self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "description": description, "createdTs": createdTs, "lastModifiedTs": lastModifiedTs, "acl": acl.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, "userACL": userAcl.flatMap { (value: UserAcl) -> ResultMap in value.resultMap }, "hasPublicACL": hasPublicAcl, "comments": comments.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, "thumbnail": thumbnail, "thumbnailSize": thumbnailSize.flatMap { (value: ThumbnailSize) -> ResultMap in value.resultMap }, "resultCount": resultCount, "isDefaultSpace": isDefaultSpace, "defaultSpaceType": defaultSpaceType])
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

  public var createdTs: String? {
    get {
      return resultMap["createdTs"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "createdTs")
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

  public var acl: [Acl]? {
    get {
      return (resultMap["acl"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Acl] in value.map { (value: ResultMap) -> Acl in Acl(unsafeResultMap: value) } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, forKey: "acl")
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

  public var comments: [Comment]? {
    get {
      return (resultMap["comments"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Comment] in value.map { (value: ResultMap) -> Comment in Comment(unsafeResultMap: value) } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, forKey: "comments")
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

  public var defaultSpaceType: DefaultSpaceType? {
    get {
      return resultMap["defaultSpaceType"] as? DefaultSpaceType
    }
    set {
      resultMap.updateValue(newValue, forKey: "defaultSpaceType")
    }
  }

  public struct Acl: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["SpaceACL"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(String.self))),
        GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
        GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(userId: String, profile: Profile, acl: SpaceACLLevel) {
      self.init(unsafeResultMap: ["__typename": "SpaceACL", "userID": userId, "profile": profile.resultMap, "acl": acl])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var userId: String {
      get {
        return resultMap["userID"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "userID")
      }
    }

    public var profile: Profile {
      get {
        return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "profile")
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

  public struct UserAcl: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["SpaceACL"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
        GraphQLField("userID", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(acl: SpaceACLLevel, userId: String) {
      self.init(unsafeResultMap: ["__typename": "SpaceACL", "acl": acl, "userID": userId])
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

    public var userId: String {
      get {
        return resultMap["userID"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "userID")
      }
    }
  }

  public struct Comment: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["SpaceCommentData"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "SpaceCommentData", "id": id])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: String? {
      get {
        return resultMap["id"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
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

public struct SpaceComments: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment spaceComments on SpaceData {
      __typename
      comments {
        __typename
        id
        userid
        profile {
          __typename
          displayName
          email
          pictureURL
        }
        createdTs
        lastModifiedTs
        comment
      }
    }
    """

  public static let possibleTypes: [String] = ["SpaceData"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("comments", type: .list(.nonNull(.object(Comment.selections)))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(comments: [Comment]? = nil) {
    self.init(unsafeResultMap: ["__typename": "SpaceData", "comments": comments.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var comments: [Comment]? {
    get {
      return (resultMap["comments"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Comment] in value.map { (value: ResultMap) -> Comment in Comment(unsafeResultMap: value) } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, forKey: "comments")
    }
  }

  public struct Comment: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["SpaceCommentData"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .scalar(String.self)),
        GraphQLField("userid", type: .scalar(String.self)),
        GraphQLField("profile", type: .object(Profile.selections)),
        GraphQLField("createdTs", type: .scalar(String.self)),
        GraphQLField("lastModifiedTs", type: .scalar(String.self)),
        GraphQLField("comment", type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String? = nil, userid: String? = nil, profile: Profile? = nil, createdTs: String? = nil, lastModifiedTs: String? = nil, comment: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "SpaceCommentData", "id": id, "userid": userid, "profile": profile.flatMap { (value: Profile) -> ResultMap in value.resultMap }, "createdTs": createdTs, "lastModifiedTs": lastModifiedTs, "comment": comment])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: String? {
      get {
        return resultMap["id"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    public var userid: String? {
      get {
        return resultMap["userid"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "userid")
      }
    }

    public var profile: Profile? {
      get {
        return (resultMap["profile"] as? ResultMap).flatMap { Profile(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "profile")
      }
    }

    public var createdTs: String? {
      get {
        return resultMap["createdTs"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "createdTs")
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

    public var comment: String? {
      get {
        return resultMap["comment"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "comment")
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

public struct SpaceContent: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment spaceContent on SpaceData {
      __typename
      entities {
        __typename
        metadata {
          __typename
          docID
          loggingResultType
        }
        spaceEntity {
          __typename
          url
          title
          snippet
          resultType
          contentType
          contentURL
          contentHeight
          contentWidth
          thumbnail
          createdBy {
            __typename
            displayName
            email
            pictureURL
          }
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["SpaceData"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("entities", type: .list(.nonNull(.object(Entity.selections)))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(entities: [Entity]? = nil) {
    self.init(unsafeResultMap: ["__typename": "SpaceData", "entities": entities.flatMap { (value: [Entity]) -> [ResultMap] in value.map { (value: Entity) -> ResultMap in value.resultMap } }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var entities: [Entity]? {
    get {
      return (resultMap["entities"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Entity] in value.map { (value: ResultMap) -> Entity in Entity(unsafeResultMap: value) } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Entity]) -> [ResultMap] in value.map { (value: Entity) -> ResultMap in value.resultMap } }, forKey: "entities")
    }
  }

  public struct Entity: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["SpaceEntity"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("metadata", type: .object(Metadatum.selections)),
        GraphQLField("spaceEntity", type: .object(SpaceEntity.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(metadata: Metadatum? = nil, spaceEntity: SpaceEntity? = nil) {
      self.init(unsafeResultMap: ["__typename": "SpaceEntity", "metadata": metadata.flatMap { (value: Metadatum) -> ResultMap in value.resultMap }, "spaceEntity": spaceEntity.flatMap { (value: SpaceEntity) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var metadata: Metadatum? {
      get {
        return (resultMap["metadata"] as? ResultMap).flatMap { Metadatum(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "metadata")
      }
    }

    public var spaceEntity: SpaceEntity? {
      get {
        return (resultMap["spaceEntity"] as? ResultMap).flatMap { SpaceEntity(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "spaceEntity")
      }
    }

    public struct Metadatum: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ResultMetadata"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("docID", type: .scalar(String.self)),
          GraphQLField("loggingResultType", type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(docId: String? = nil, loggingResultType: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "ResultMetadata", "docID": docId, "loggingResultType": loggingResultType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The DocID for this item
      /// See: https://github.com/neevaco/neeva/blob/41e1f138129605b106dc88d456ed50f1b9da4578/docs/doc.go#L18-L26
      public var docId: String? {
        get {
          return resultMap["docID"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "docID")
        }
      }

      /// LoggingResultType is result type used for logging
      public var loggingResultType: String? {
        get {
          return resultMap["loggingResultType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "loggingResultType")
        }
      }
    }

    public struct SpaceEntity: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SpaceEntityData"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .scalar(String.self)),
          GraphQLField("title", type: .scalar(String.self)),
          GraphQLField("snippet", type: .scalar(String.self)),
          GraphQLField("resultType", type: .scalar(String.self)),
          GraphQLField("contentType", type: .scalar(String.self)),
          GraphQLField("contentURL", type: .scalar(String.self)),
          GraphQLField("contentHeight", type: .scalar(Int.self)),
          GraphQLField("contentWidth", type: .scalar(Int.self)),
          GraphQLField("thumbnail", type: .scalar(String.self)),
          GraphQLField("createdBy", type: .object(CreatedBy.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(url: String? = nil, title: String? = nil, snippet: String? = nil, resultType: String? = nil, contentType: String? = nil, contentUrl: String? = nil, contentHeight: Int? = nil, contentWidth: Int? = nil, thumbnail: String? = nil, createdBy: CreatedBy? = nil) {
        self.init(unsafeResultMap: ["__typename": "SpaceEntityData", "url": url, "title": title, "snippet": snippet, "resultType": resultType, "contentType": contentType, "contentURL": contentUrl, "contentHeight": contentHeight, "contentWidth": contentWidth, "thumbnail": thumbnail, "createdBy": createdBy.flatMap { (value: CreatedBy) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var url: String? {
        get {
          return resultMap["url"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "url")
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

      public var snippet: String? {
        get {
          return resultMap["snippet"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "snippet")
        }
      }

      public var resultType: String? {
        get {
          return resultMap["resultType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "resultType")
        }
      }

      public var contentType: String? {
        get {
          return resultMap["contentType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "contentType")
        }
      }

      public var contentUrl: String? {
        get {
          return resultMap["contentURL"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "contentURL")
        }
      }

      public var contentHeight: Int? {
        get {
          return resultMap["contentHeight"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "contentHeight")
        }
      }

      public var contentWidth: Int? {
        get {
          return resultMap["contentWidth"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "contentWidth")
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

      public var createdBy: CreatedBy? {
        get {
          return (resultMap["createdBy"] as? ResultMap).flatMap { CreatedBy(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "createdBy")
        }
      }

      public struct CreatedBy: GraphQLSelectionSet {
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
