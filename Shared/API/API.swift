// swift-format-ignore-file
// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// Input type for client logs.
/// 
/// Client logs are generic, and cover every type of log that the client
/// may want to pass, including counters, pingbacks, trace information, errors,
/// etc. Log messages from the client are batched, and each batch contains
/// base information invariant across the lifetime of the client.
public struct ClientLogInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - base: Base information to send along with a log batch. This information is
  /// invariant across each log message within a batch.
  /// 
  /// DEPRECATED:
  /// Removed from client code 2020-07-31
  ///   - web: 0.2.105
  ///   - ios: 0.4.1
  ///   - log: One or more log messages. Since log messages can be batched, we expose
  /// an interface for sending multiple logs at once. If this list is empty,
  /// the log call is a NOOP.
  public init(base: Swift.Optional<ClientLogBase?> = nil, log: [ClientLog]) {
    graphQLMap = ["base": base, "log": log]
  }

  /// Base information to send along with a log batch. This information is
  /// invariant across each log message within a batch.
  /// 
  /// DEPRECATED:
  /// Removed from client code 2020-07-31
  /// - web: 0.2.105
  /// - ios: 0.4.1
  public var base: Swift.Optional<ClientLogBase?> {
    get {
      return graphQLMap["base"] as? Swift.Optional<ClientLogBase?> ?? Swift.Optional<ClientLogBase?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "base")
    }
  }

  /// One or more log messages. Since log messages can be batched, we expose
  /// an interface for sending multiple logs at once. If this list is empty,
  /// the log call is a NOOP.
  public var log: [ClientLog] {
    get {
      return graphQLMap["log"] as! [ClientLog]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "log")
    }
  }
}

public struct ClientLogBase: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id: Which client this log request comes from. This should be of the form
  /// used to identify the client on its platform; i.e. 'co.neeva.app.ios'
  /// or 'co.neeva.app.web'.
  ///   - version: The version number of the client. Version numbering will vary based
  /// on the client ID.
  ///   - environment: The client environment, e.g. dev or prod.
  public init(id: String, version: String, environment: ClientLogEnvironment) {
    graphQLMap = ["id": id, "version": version, "environment": environment]
  }

  /// Which client this log request comes from. This should be of the form
  /// used to identify the client on its platform; i.e. 'co.neeva.app.ios'
  /// or 'co.neeva.app.web'.
  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  /// The version number of the client. Version numbering will vary based
  /// on the client ID.
  public var version: String {
    get {
      return graphQLMap["version"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "version")
    }
  }

  /// The client environment, e.g. dev or prod.
  public var environment: ClientLogEnvironment {
    get {
      return graphQLMap["environment"] as! ClientLogEnvironment
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "environment")
    }
  }
}

public enum ClientLogEnvironment: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case dev
  case prod
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Dev": self = .dev
      case "Prod": self = .prod
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .dev: return "Dev"
      case .prod: return "Prod"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogEnvironment, rhs: ClientLogEnvironment) -> Bool {
    switch (lhs, rhs) {
      case (.dev, .dev): return true
      case (.prod, .prod): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogEnvironment] {
    return [
      .dev,
      .prod,
    ]
  }
}

/// A client log message. This represents a single log message sent by the
/// client as part of a log batch. All but one of the subfields should be
/// nil.
public struct ClientLog: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - counter
  ///   - graphql
  ///   - tracking
  ///   - interactionEvent: DEPRECATED
  /// Moving to new interaction input, InteractionEventInput
  /// Version:
  /// - webui: 0.2.18
  /// - nativeui: 0.2.20
  /// Date: 12/27/2019.
  ///   - interactionV3Event
  ///   - searchPerfEvent
  ///   - suggestPerfEvent
  ///   - perfTrace
  public init(counter: Swift.Optional<ClientLogCounter?> = nil, graphql: Swift.Optional<ClientLogGraphql?> = nil, tracking: Swift.Optional<ClientLogTracking?> = nil, interactionEvent: Swift.Optional<InteractionEventInput?> = nil, interactionV3Event: Swift.Optional<InteractionV3EventInput?> = nil, searchPerfEvent: Swift.Optional<SearchPerfEventInput?> = nil, suggestPerfEvent: Swift.Optional<SuggestPerfEventInput?> = nil, perfTrace: Swift.Optional<PerfTraceInput?> = nil) {
    graphQLMap = ["counter": counter, "graphql": graphql, "tracking": tracking, "interactionEvent": interactionEvent, "interactionV3Event": interactionV3Event, "searchPerfEvent": searchPerfEvent, "suggestPerfEvent": suggestPerfEvent, "perfTrace": perfTrace]
  }

  public var counter: Swift.Optional<ClientLogCounter?> {
    get {
      return graphQLMap["counter"] as? Swift.Optional<ClientLogCounter?> ?? Swift.Optional<ClientLogCounter?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "counter")
    }
  }

  public var graphql: Swift.Optional<ClientLogGraphql?> {
    get {
      return graphQLMap["graphql"] as? Swift.Optional<ClientLogGraphql?> ?? Swift.Optional<ClientLogGraphql?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "graphql")
    }
  }

  public var tracking: Swift.Optional<ClientLogTracking?> {
    get {
      return graphQLMap["tracking"] as? Swift.Optional<ClientLogTracking?> ?? Swift.Optional<ClientLogTracking?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tracking")
    }
  }

  /// DEPRECATED
  /// Moving to new interaction input, InteractionEventInput
  /// Version:
  /// - webui: 0.2.18
  /// - nativeui: 0.2.20
  /// Date: 12/27/2019.
  public var interactionEvent: Swift.Optional<InteractionEventInput?> {
    get {
      return graphQLMap["interactionEvent"] as? Swift.Optional<InteractionEventInput?> ?? Swift.Optional<InteractionEventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "interactionEvent")
    }
  }

  public var interactionV3Event: Swift.Optional<InteractionV3EventInput?> {
    get {
      return graphQLMap["interactionV3Event"] as? Swift.Optional<InteractionV3EventInput?> ?? Swift.Optional<InteractionV3EventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "interactionV3Event")
    }
  }

  public var searchPerfEvent: Swift.Optional<SearchPerfEventInput?> {
    get {
      return graphQLMap["searchPerfEvent"] as? Swift.Optional<SearchPerfEventInput?> ?? Swift.Optional<SearchPerfEventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "searchPerfEvent")
    }
  }

  public var suggestPerfEvent: Swift.Optional<SuggestPerfEventInput?> {
    get {
      return graphQLMap["suggestPerfEvent"] as? Swift.Optional<SuggestPerfEventInput?> ?? Swift.Optional<SuggestPerfEventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "suggestPerfEvent")
    }
  }

  public var perfTrace: Swift.Optional<PerfTraceInput?> {
    get {
      return graphQLMap["perfTrace"] as? Swift.Optional<PerfTraceInput?> ?? Swift.Optional<PerfTraceInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "perfTrace")
    }
  }
}

/// Information to be exposed as a counter. The effect will be to increment
/// whatever path is provided.
public struct ClientLogCounter: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - path: The path of the counter, which may be an arbitrary string.
  ///   - attributes: Arbitrary key/value pairs to associate with the counter.
  public init(path: String, attributes: Swift.Optional<[ClientLogCounterAttribute]?> = nil) {
    graphQLMap = ["path": path, "attributes": attributes]
  }

  /// The path of the counter, which may be an arbitrary string.
  public var path: String {
    get {
      return graphQLMap["path"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "path")
    }
  }

  /// Arbitrary key/value pairs to associate with the counter.
  public var attributes: Swift.Optional<[ClientLogCounterAttribute]?> {
    get {
      return graphQLMap["attributes"] as? Swift.Optional<[ClientLogCounterAttribute]?> ?? Swift.Optional<[ClientLogCounterAttribute]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributes")
    }
  }
}

public struct ClientLogCounterAttribute: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - key
  ///   - value
  public init(key: Swift.Optional<String?> = nil, value: Swift.Optional<String?> = nil) {
    graphQLMap = ["key": key, "value": value]
  }

  public var key: Swift.Optional<String?> {
    get {
      return graphQLMap["key"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  public var value: Swift.Optional<String?> {
    get {
      return graphQLMap["value"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "value")
    }
  }
}

/// Information about a graphql call from the client side.
public struct ClientLogGraphql: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - name: The query name.
  ///   - type: The type of query, Mutation or Query.
  ///   - status: The status of the query as of this log message.
  ///   - elapsedTimeMs: If the status is Complete or Error (in other words, if the query is
  /// completed), this will give the total time elapsed from "Loading"
  /// to the completion status.
  ///   - errorInfo: Error information about this query. If the query does not end in an
  /// error, then this will be empty.
  public init(name: Swift.Optional<String?> = nil, type: Swift.Optional<ClientLogGraphqlType?> = nil, status: Swift.Optional<ClientLogGraphqlStatus?> = nil, elapsedTimeMs: Swift.Optional<Int?> = nil, errorInfo: Swift.Optional<ClientLogGraphqlErrorInfo?> = nil) {
    graphQLMap = ["name": name, "type": type, "status": status, "elapsedTimeMs": elapsedTimeMs, "errorInfo": errorInfo]
  }

  /// The query name.
  public var name: Swift.Optional<String?> {
    get {
      return graphQLMap["name"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  /// The type of query, Mutation or Query.
  public var type: Swift.Optional<ClientLogGraphqlType?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<ClientLogGraphqlType?> ?? Swift.Optional<ClientLogGraphqlType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// The status of the query as of this log message.
  public var status: Swift.Optional<ClientLogGraphqlStatus?> {
    get {
      return graphQLMap["status"] as? Swift.Optional<ClientLogGraphqlStatus?> ?? Swift.Optional<ClientLogGraphqlStatus?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }

  /// If the status is Complete or Error (in other words, if the query is
  /// completed), this will give the total time elapsed from "Loading"
  /// to the completion status.
  public var elapsedTimeMs: Swift.Optional<Int?> {
    get {
      return graphQLMap["elapsedTimeMs"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "elapsedTimeMs")
    }
  }

  /// Error information about this query. If the query does not end in an
  /// error, then this will be empty.
  public var errorInfo: Swift.Optional<ClientLogGraphqlErrorInfo?> {
    get {
      return graphQLMap["errorInfo"] as? Swift.Optional<ClientLogGraphqlErrorInfo?> ?? Swift.Optional<ClientLogGraphqlErrorInfo?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "errorInfo")
    }
  }
}

public enum ClientLogGraphqlType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case query
  case mutation
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Query": self = .query
      case "Mutation": self = .mutation
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .query: return "Query"
      case .mutation: return "Mutation"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogGraphqlType, rhs: ClientLogGraphqlType) -> Bool {
    switch (lhs, rhs) {
      case (.query, .query): return true
      case (.mutation, .mutation): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogGraphqlType] {
    return [
      .query,
      .mutation,
    ]
  }
}

public enum ClientLogGraphqlStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case started
  case complete
  case error
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Started": self = .started
      case "Complete": self = .complete
      case "Error": self = .error
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .started: return "Started"
      case .complete: return "Complete"
      case .error: return "Error"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogGraphqlStatus, rhs: ClientLogGraphqlStatus) -> Bool {
    switch (lhs, rhs) {
      case (.started, .started): return true
      case (.complete, .complete): return true
      case (.error, .error): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogGraphqlStatus] {
    return [
      .started,
      .complete,
      .error,
    ]
  }
}

public struct ClientLogGraphqlErrorInfo: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - type: Type of the error.
  ///   - httpResponseCode: HTTP response code, if one exists.
  public init(type: Swift.Optional<ClientLogGraphqlErrorInfoType?> = nil, httpResponseCode: Swift.Optional<Int?> = nil) {
    graphQLMap = ["type": type, "httpResponseCode": httpResponseCode]
  }

  /// Type of the error.
  public var type: Swift.Optional<ClientLogGraphqlErrorInfoType?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<ClientLogGraphqlErrorInfoType?> ?? Swift.Optional<ClientLogGraphqlErrorInfoType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// HTTP response code, if one exists.
  public var httpResponseCode: Swift.Optional<Int?> {
    get {
      return graphQLMap["httpResponseCode"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "httpResponseCode")
    }
  }
}

public enum ClientLogGraphqlErrorInfoType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case httpError
  case graphqlError
  case networkError
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "HttpError": self = .httpError
      case "GraphqlError": self = .graphqlError
      case "NetworkError": self = .networkError
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .httpError: return "HttpError"
      case .graphqlError: return "GraphqlError"
      case .networkError: return "NetworkError"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogGraphqlErrorInfoType, rhs: ClientLogGraphqlErrorInfoType) -> Bool {
    switch (lhs, rhs) {
      case (.httpError, .httpError): return true
      case (.graphqlError, .graphqlError): return true
      case (.networkError, .networkError): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogGraphqlErrorInfoType] {
    return [
      .httpError,
      .graphqlError,
      .networkError,
    ]
  }
}

public struct ClientLogTracking: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - topDomain: Top domain of the frame
  ///   - frameDomain: Domain of the frame which loads the tracking url
  ///   - originAndPath: Origin and path of the tracker url
  ///   - logType: Type of the data, generated rule or potential tracker
  public init(topDomain: String, frameDomain: String, originAndPath: String, logType: Swift.Optional<ClientLogTrackingLogType?> = nil) {
    graphQLMap = ["topDomain": topDomain, "frameDomain": frameDomain, "originAndPath": originAndPath, "logType": logType]
  }

  /// Top domain of the frame
  public var topDomain: String {
    get {
      return graphQLMap["topDomain"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "topDomain")
    }
  }

  /// Domain of the frame which loads the tracking url
  public var frameDomain: String {
    get {
      return graphQLMap["frameDomain"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "frameDomain")
    }
  }

  /// Origin and path of the tracker url
  public var originAndPath: String {
    get {
      return graphQLMap["originAndPath"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "originAndPath")
    }
  }

  /// Type of the data, generated rule or potential tracker
  public var logType: Swift.Optional<ClientLogTrackingLogType?> {
    get {
      return graphQLMap["logType"] as? Swift.Optional<ClientLogTrackingLogType?> ?? Swift.Optional<ClientLogTrackingLogType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "logType")
    }
  }
}

public enum ClientLogTrackingLogType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Potential tracker, url appeared in 3P context and domain not owned by the main site.
  case potentialTracker
  /// Small gif returned in response. This is a beacon url
  case smallGifRule
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "PotentialTracker": self = .potentialTracker
      case "SmallGifRule": self = .smallGifRule
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .potentialTracker: return "PotentialTracker"
      case .smallGifRule: return "SmallGifRule"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogTrackingLogType, rhs: ClientLogTrackingLogType) -> Bool {
    switch (lhs, rhs) {
      case (.potentialTracker, .potentialTracker): return true
      case (.smallGifRule, .smallGifRule): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogTrackingLogType] {
    return [
      .potentialTracker,
      .smallGifRule,
    ]
  }
}

/// Input type for logInteraction mutation.
/// 
/// Though this is not officially deprecated (and still works), new interactions
/// should be added to the interactionV3Event instead.
public struct InteractionEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - loggingContexts: Array of all logging contexts
  ///   - pageType: Type of Page search, activity, etc
  ///   - serverResultType: Type of result
  ///   - parentEventId: Event ID of query/activity event which generated this result
  ///   - resultId: DocId of the result for which the event being recorded
  ///   - type: Type of interaction
  ///   - pageEventAttributes: Page Attribute data
  ///   - resultGroupAttributes: Result Group Attributes
  public init(loggingContexts: Swift.Optional<[LoggingContext]?> = nil, pageType: Swift.Optional<String?> = nil, serverResultType: Swift.Optional<String?> = nil, parentEventId: Swift.Optional<String?> = nil, resultId: Swift.Optional<String?> = nil, type: Swift.Optional<InteractionType?> = nil, pageEventAttributes: Swift.Optional<PageEventAttributes?> = nil, resultGroupAttributes: Swift.Optional<ResultGroupAttributes?> = nil) {
    graphQLMap = ["loggingContexts": loggingContexts, "pageType": pageType, "serverResultType": serverResultType, "parentEventID": parentEventId, "resultID": resultId, "type": type, "pageEventAttributes": pageEventAttributes, "resultGroupAttributes": resultGroupAttributes]
  }

  /// Array of all logging contexts
  public var loggingContexts: Swift.Optional<[LoggingContext]?> {
    get {
      return graphQLMap["loggingContexts"] as? Swift.Optional<[LoggingContext]?> ?? Swift.Optional<[LoggingContext]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "loggingContexts")
    }
  }

  /// Type of Page search, activity, etc
  public var pageType: Swift.Optional<String?> {
    get {
      return graphQLMap["pageType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "pageType")
    }
  }

  /// Type of result
  public var serverResultType: Swift.Optional<String?> {
    get {
      return graphQLMap["serverResultType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "serverResultType")
    }
  }

  /// Event ID of query/activity event which generated this result
  public var parentEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["parentEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "parentEventID")
    }
  }

  /// DocId of the result for which the event being recorded
  public var resultId: Swift.Optional<String?> {
    get {
      return graphQLMap["resultID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultID")
    }
  }

  /// Type of interaction
  public var type: Swift.Optional<InteractionType?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<InteractionType?> ?? Swift.Optional<InteractionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// Page Attribute data
  public var pageEventAttributes: Swift.Optional<PageEventAttributes?> {
    get {
      return graphQLMap["pageEventAttributes"] as? Swift.Optional<PageEventAttributes?> ?? Swift.Optional<PageEventAttributes?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "pageEventAttributes")
    }
  }

  /// Result Group Attributes
  public var resultGroupAttributes: Swift.Optional<ResultGroupAttributes?> {
    get {
      return graphQLMap["resultGroupAttributes"] as? Swift.Optional<ResultGroupAttributes?> ?? Swift.Optional<ResultGroupAttributes?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultGroupAttributes")
    }
  }
}

/// Logging context collects all ambient data, not specific to element type.
/// Individual contexts may contain different macros based on it's location in hierarchy.
/// For eg. Top level context may collect macros related to page
public struct LoggingContext: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - docId
  ///   - macros
  ///   - category: Logging category, e.g. page/group/container/result.
  ///   - serverResultType: ResultType sent by metadata
  ///   - placeActionType: Type of action on place results
  ///   - universalActionType: Type of action on carousel links
  ///   - oneBoxActionType: Type of action on onebox
  ///   - resultGroupActionType: Type of action on result group
  ///   - resultActionType: An ActionLink or Link from a result
  public init(docId: Swift.Optional<String?> = nil, macros: Swift.Optional<[PopulatedClientMacro]?> = nil, category: Swift.Optional<String?> = nil, serverResultType: Swift.Optional<String?> = nil, placeActionType: Swift.Optional<PlaceActionType?> = nil, universalActionType: Swift.Optional<UniversalActionType?> = nil, oneBoxActionType: Swift.Optional<OneBoxActionType?> = nil, resultGroupActionType: Swift.Optional<ResultGroupActionType?> = nil, resultActionType: Swift.Optional<ResultActionType?> = nil) {
    graphQLMap = ["docID": docId, "macros": macros, "category": category, "serverResultType": serverResultType, "placeActionType": placeActionType, "universalActionType": universalActionType, "oneBoxActionType": oneBoxActionType, "resultGroupActionType": resultGroupActionType, "resultActionType": resultActionType]
  }

  public var docId: Swift.Optional<String?> {
    get {
      return graphQLMap["docID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "docID")
    }
  }

  public var macros: Swift.Optional<[PopulatedClientMacro]?> {
    get {
      return graphQLMap["macros"] as? Swift.Optional<[PopulatedClientMacro]?> ?? Swift.Optional<[PopulatedClientMacro]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "macros")
    }
  }

  /// Logging category, e.g. page/group/container/result.
  public var category: Swift.Optional<String?> {
    get {
      return graphQLMap["category"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  /// ResultType sent by metadata
  public var serverResultType: Swift.Optional<String?> {
    get {
      return graphQLMap["serverResultType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "serverResultType")
    }
  }

  /// Type of action on place results
  public var placeActionType: Swift.Optional<PlaceActionType?> {
    get {
      return graphQLMap["placeActionType"] as? Swift.Optional<PlaceActionType?> ?? Swift.Optional<PlaceActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "placeActionType")
    }
  }

  /// Type of action on carousel links
  public var universalActionType: Swift.Optional<UniversalActionType?> {
    get {
      return graphQLMap["universalActionType"] as? Swift.Optional<UniversalActionType?> ?? Swift.Optional<UniversalActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "universalActionType")
    }
  }

  /// Type of action on onebox
  public var oneBoxActionType: Swift.Optional<OneBoxActionType?> {
    get {
      return graphQLMap["oneBoxActionType"] as? Swift.Optional<OneBoxActionType?> ?? Swift.Optional<OneBoxActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "oneBoxActionType")
    }
  }

  /// Type of action on result group
  public var resultGroupActionType: Swift.Optional<ResultGroupActionType?> {
    get {
      return graphQLMap["resultGroupActionType"] as? Swift.Optional<ResultGroupActionType?> ?? Swift.Optional<ResultGroupActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultGroupActionType")
    }
  }

  /// An ActionLink or Link from a result
  public var resultActionType: Swift.Optional<ResultActionType?> {
    get {
      return graphQLMap["resultActionType"] as? Swift.Optional<ResultActionType?> ?? Swift.Optional<ResultActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultActionType")
    }
  }
}

/// A macro populated and returned by the client.
public struct PopulatedClientMacro: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - type: Type of the macro being populated.
  ///   - value: Client-populated value of the macro. The format of this may vary depending
  /// on the type of the macro being returned. Please see documentation on the
  /// ClientMacroType enum for more details about format.
  public init(type: ClientMacroType, value: String) {
    graphQLMap = ["type": type, "value": value]
  }

  /// Type of the macro being populated.
  public var type: ClientMacroType {
    get {
      return graphQLMap["type"] as! ClientMacroType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// Client-populated value of the macro. The format of this may vary depending
  /// on the type of the macro being returned. Please see documentation on the
  /// ClientMacroType enum for more details about format.
  public var value: String {
    get {
      return graphQLMap["value"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "value")
    }
  }
}

/// Enum of types of data that the client should be able to fill out and
/// report when returning log messages.
public enum ClientMacroType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Height of the viewport in pixels.
  case viewportHeight
  /// Width of the viewport in pixels.
  case viewportWidth
  /// Height of the scroll in pixels.
  case scrollHeight
  /// Right or left click
  case clickType
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ViewportHeight": self = .viewportHeight
      case "ViewportWidth": self = .viewportWidth
      case "ScrollHeight": self = .scrollHeight
      case "ClickType": self = .clickType
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .viewportHeight: return "ViewportHeight"
      case .viewportWidth: return "ViewportWidth"
      case .scrollHeight: return "ScrollHeight"
      case .clickType: return "ClickType"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientMacroType, rhs: ClientMacroType) -> Bool {
    switch (lhs, rhs) {
      case (.viewportHeight, .viewportHeight): return true
      case (.viewportWidth, .viewportWidth): return true
      case (.scrollHeight, .scrollHeight): return true
      case (.clickType, .clickType): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientMacroType] {
    return [
      .viewportHeight,
      .viewportWidth,
      .scrollHeight,
      .clickType,
    ]
  }
}

/// Enum for action taken on on place click
public enum PlaceActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Clicked call of local listing
  case call
  /// Clicked on telephone to call
  case telephone
  /// Clicked direction of local listing
  case direction
  /// Clicked on Address of the listing
  case address
  /// Clicked website of local listing
  case website
  /// Clicked on website url
  case websiteUrl
  /// Clicked on Place Name
  case name
  /// Clicked on Yelp URL
  case yelpUrl
  /// Clicked on operating status/hours
  case operatingStatus
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Call": self = .call
      case "Telephone": self = .telephone
      case "Direction": self = .direction
      case "Address": self = .address
      case "Website": self = .website
      case "WebsiteUrl": self = .websiteUrl
      case "Name": self = .name
      case "YelpUrl": self = .yelpUrl
      case "OperatingStatus": self = .operatingStatus
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .call: return "Call"
      case .telephone: return "Telephone"
      case .direction: return "Direction"
      case .address: return "Address"
      case .website: return "Website"
      case .websiteUrl: return "WebsiteUrl"
      case .name: return "Name"
      case .yelpUrl: return "YelpUrl"
      case .operatingStatus: return "OperatingStatus"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PlaceActionType, rhs: PlaceActionType) -> Bool {
    switch (lhs, rhs) {
      case (.call, .call): return true
      case (.telephone, .telephone): return true
      case (.direction, .direction): return true
      case (.address, .address): return true
      case (.website, .website): return true
      case (.websiteUrl, .websiteUrl): return true
      case (.name, .name): return true
      case (.yelpUrl, .yelpUrl): return true
      case (.operatingStatus, .operatingStatus): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PlaceActionType] {
    return [
      .call,
      .telephone,
      .direction,
      .address,
      .website,
      .websiteUrl,
      .name,
      .yelpUrl,
      .operatingStatus,
    ]
  }
}

public enum UniversalActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// User clicked section link on top of the universal
  case sectionTitleClick
  /// More click
  case moreClick
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "SectionTitleClick": self = .sectionTitleClick
      case "MoreClick": self = .moreClick
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .sectionTitleClick: return "SectionTitleClick"
      case .moreClick: return "MoreClick"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: UniversalActionType, rhs: UniversalActionType) -> Bool {
    switch (lhs, rhs) {
      case (.sectionTitleClick, .sectionTitleClick): return true
      case (.moreClick, .moreClick): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [UniversalActionType] {
    return [
      .sectionTitleClick,
      .moreClick,
    ]
  }
}

public enum OneBoxActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Opened onebox
  case `open`
  /// Closed onebox
  case close
  /// Temperature unit is changed
  case tempUnitChange
  /// Daily forecast change
  case dailyForecast
  /// Stock time range
  case stockTimeRange
  /// The user clicks expand
  case expand
  /// The user clicks collapse
  case collapse
  /// The user clicks previous
  case previous
  /// The user clicks next
  case next
  /// The user clicks to switch tab
  case switchTab
  /// User clicked to change product in buying guide
  case buyingGuideNavigationClick
  /// The user clicks expand on a rich caption
  case richCaptionExpand
  /// User clicked to view the user who wrote a tech Q 'n A answer
  case techQnaAttributionClick
  /// User clicked to toggle the full tech Q 'n A result
  case techQnaShowAllToggleClick
  /// User click to expand RHS
  case expandRhs
  /// User clicks on the primary action URL
  case primaryActionUrl
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Open": self = .open
      case "Close": self = .close
      case "TempUnitChange": self = .tempUnitChange
      case "DailyForecast": self = .dailyForecast
      case "StockTimeRange": self = .stockTimeRange
      case "Expand": self = .expand
      case "Collapse": self = .collapse
      case "Previous": self = .previous
      case "Next": self = .next
      case "SwitchTab": self = .switchTab
      case "BuyingGuideNavigationClick": self = .buyingGuideNavigationClick
      case "RichCaptionExpand": self = .richCaptionExpand
      case "TechQNAAttributionClick": self = .techQnaAttributionClick
      case "TechQNAShowAllToggleClick": self = .techQnaShowAllToggleClick
      case "ExpandRhs": self = .expandRhs
      case "PrimaryActionURL": self = .primaryActionUrl
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .open: return "Open"
      case .close: return "Close"
      case .tempUnitChange: return "TempUnitChange"
      case .dailyForecast: return "DailyForecast"
      case .stockTimeRange: return "StockTimeRange"
      case .expand: return "Expand"
      case .collapse: return "Collapse"
      case .previous: return "Previous"
      case .next: return "Next"
      case .switchTab: return "SwitchTab"
      case .buyingGuideNavigationClick: return "BuyingGuideNavigationClick"
      case .richCaptionExpand: return "RichCaptionExpand"
      case .techQnaAttributionClick: return "TechQNAAttributionClick"
      case .techQnaShowAllToggleClick: return "TechQNAShowAllToggleClick"
      case .expandRhs: return "ExpandRhs"
      case .primaryActionUrl: return "PrimaryActionURL"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: OneBoxActionType, rhs: OneBoxActionType) -> Bool {
    switch (lhs, rhs) {
      case (.open, .open): return true
      case (.close, .close): return true
      case (.tempUnitChange, .tempUnitChange): return true
      case (.dailyForecast, .dailyForecast): return true
      case (.stockTimeRange, .stockTimeRange): return true
      case (.expand, .expand): return true
      case (.collapse, .collapse): return true
      case (.previous, .previous): return true
      case (.next, .next): return true
      case (.switchTab, .switchTab): return true
      case (.buyingGuideNavigationClick, .buyingGuideNavigationClick): return true
      case (.richCaptionExpand, .richCaptionExpand): return true
      case (.techQnaAttributionClick, .techQnaAttributionClick): return true
      case (.techQnaShowAllToggleClick, .techQnaShowAllToggleClick): return true
      case (.expandRhs, .expandRhs): return true
      case (.primaryActionUrl, .primaryActionUrl): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [OneBoxActionType] {
    return [
      .open,
      .close,
      .tempUnitChange,
      .dailyForecast,
      .stockTimeRange,
      .expand,
      .collapse,
      .previous,
      .next,
      .switchTab,
      .buyingGuideNavigationClick,
      .richCaptionExpand,
      .techQnaAttributionClick,
      .techQnaShowAllToggleClick,
      .expandRhs,
      .primaryActionUrl,
    ]
  }
}

/// Result group action type
public enum ResultGroupActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The user clicks show more
  case showMore
  /// The user clicks show less
  case showLess
  /// The user clicks undo done
  case done
  /// The user clicks undo done
  case undoDone
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ShowMore": self = .showMore
      case "ShowLess": self = .showLess
      case "Done": self = .done
      case "UndoDone": self = .undoDone
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .showMore: return "ShowMore"
      case .showLess: return "ShowLess"
      case .done: return "Done"
      case .undoDone: return "UndoDone"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ResultGroupActionType, rhs: ResultGroupActionType) -> Bool {
    switch (lhs, rhs) {
      case (.showMore, .showMore): return true
      case (.showLess, .showLess): return true
      case (.done, .done): return true
      case (.undoDone, .undoDone): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ResultGroupActionType] {
    return [
      .showMore,
      .showLess,
      .done,
      .undoDone,
    ]
  }
}

public enum ResultActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Clicked ReviewWidget All Reviews
  case allReviewsClick
  /// Clicked to CamelCamelCamel
  case camelCamelCamelPricePage
  /// Clicked QNA All Questions
  case qnaAllQuestionsClick
  /// Clicked on Expert Review RHS
  case expertReview
  /// Clicked on Retailer item on RHS
  case retailer
  /// Clicked on Photos item on RHS
  case photo
  /// Clicked on Related Products on RHS
  case relatedProduct
  /// Rich Entity click on header URL
  case richEntityHeaderLink
  /// Rich Entity social profile click
  case richEntitySocialProfile
  /// Rich Entity fact link click
  case richEntityFact
  /// Rich entity click on inline Wikipedia URL
  case richEntityInlineLink
  /// Rich entity click on related search entity
  case richEntityRelatedSearchClick
  /// Rich entity show entire snippet paragraph
  case richEntityToggleFullSnippet
  /// Rich entity show all facts
  case richEntityToggleAllFacts
  /// Rich entity show all facts values
  case richEntityToggleAllValues
  /// Rich entity click on a TV episode
  case richEntityTvEpisodeClick
  /// Rich entity click to toggle all episodes view
  case richEntityTvEpisodeAllToggle
  /// User clicked to view the Tweet on twitter.com
  case twitterStatusClick
  /// User clicked to view the link from the Tweet
  case twitterDisplayUrlClick
  /// User clicked to view the tweet owner's profile
  case twitterProfileUrlClick
  /// User clicked to view KG related answer
  case knowledgeGraphAnswerNodeClick
  /// Deprecated
  case techQnaAttributionClick
  /// User clicked to change product in buying guide
  case buyingGuideNavigationClick
  /// User clicked out from a rich caption
  case richCaptionClick
  /// User click to trigger internal query
  case internalQuery
  /// User clicks on an inline SRP product result
  case inlineSrpProduct
  /// User clicks to toggle a related QnA result
  case relatedQnaToggle
  /// User clicks to view the full answer from a related QnA result
  case relatedQnAActionLink
  /// User clicks on purchase link
  case purchaseLink
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "AllReviewsClick": self = .allReviewsClick
      case "CamelCamelCamelPricePage": self = .camelCamelCamelPricePage
      case "QNAAllQuestionsClick": self = .qnaAllQuestionsClick
      case "ExpertReview": self = .expertReview
      case "Retailer": self = .retailer
      case "Photo": self = .photo
      case "RelatedProduct": self = .relatedProduct
      case "RichEntityHeaderLink": self = .richEntityHeaderLink
      case "RichEntitySocialProfile": self = .richEntitySocialProfile
      case "RichEntityFact": self = .richEntityFact
      case "RichEntityInlineLink": self = .richEntityInlineLink
      case "RichEntityRelatedSearchClick": self = .richEntityRelatedSearchClick
      case "RichEntityToggleFullSnippet": self = .richEntityToggleFullSnippet
      case "RichEntityToggleAllFacts": self = .richEntityToggleAllFacts
      case "RichEntityToggleAllValues": self = .richEntityToggleAllValues
      case "RichEntityTVEpisodeClick": self = .richEntityTvEpisodeClick
      case "RichEntityTVEpisodeAllToggle": self = .richEntityTvEpisodeAllToggle
      case "TwitterStatusClick": self = .twitterStatusClick
      case "TwitterDisplayURLClick": self = .twitterDisplayUrlClick
      case "TwitterProfileURLClick": self = .twitterProfileUrlClick
      case "KnowledgeGraphAnswerNodeClick": self = .knowledgeGraphAnswerNodeClick
      case "TechQNAAttributionClick": self = .techQnaAttributionClick
      case "BuyingGuideNavigationClick": self = .buyingGuideNavigationClick
      case "RichCaptionClick": self = .richCaptionClick
      case "InternalQuery": self = .internalQuery
      case "InlineSrpProduct": self = .inlineSrpProduct
      case "RelatedQnaToggle": self = .relatedQnaToggle
      case "RelatedQnAActionLink": self = .relatedQnAActionLink
      case "PurchaseLink": self = .purchaseLink
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .allReviewsClick: return "AllReviewsClick"
      case .camelCamelCamelPricePage: return "CamelCamelCamelPricePage"
      case .qnaAllQuestionsClick: return "QNAAllQuestionsClick"
      case .expertReview: return "ExpertReview"
      case .retailer: return "Retailer"
      case .photo: return "Photo"
      case .relatedProduct: return "RelatedProduct"
      case .richEntityHeaderLink: return "RichEntityHeaderLink"
      case .richEntitySocialProfile: return "RichEntitySocialProfile"
      case .richEntityFact: return "RichEntityFact"
      case .richEntityInlineLink: return "RichEntityInlineLink"
      case .richEntityRelatedSearchClick: return "RichEntityRelatedSearchClick"
      case .richEntityToggleFullSnippet: return "RichEntityToggleFullSnippet"
      case .richEntityToggleAllFacts: return "RichEntityToggleAllFacts"
      case .richEntityToggleAllValues: return "RichEntityToggleAllValues"
      case .richEntityTvEpisodeClick: return "RichEntityTVEpisodeClick"
      case .richEntityTvEpisodeAllToggle: return "RichEntityTVEpisodeAllToggle"
      case .twitterStatusClick: return "TwitterStatusClick"
      case .twitterDisplayUrlClick: return "TwitterDisplayURLClick"
      case .twitterProfileUrlClick: return "TwitterProfileURLClick"
      case .knowledgeGraphAnswerNodeClick: return "KnowledgeGraphAnswerNodeClick"
      case .techQnaAttributionClick: return "TechQNAAttributionClick"
      case .buyingGuideNavigationClick: return "BuyingGuideNavigationClick"
      case .richCaptionClick: return "RichCaptionClick"
      case .internalQuery: return "InternalQuery"
      case .inlineSrpProduct: return "InlineSrpProduct"
      case .relatedQnaToggle: return "RelatedQnaToggle"
      case .relatedQnAActionLink: return "RelatedQnAActionLink"
      case .purchaseLink: return "PurchaseLink"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ResultActionType, rhs: ResultActionType) -> Bool {
    switch (lhs, rhs) {
      case (.allReviewsClick, .allReviewsClick): return true
      case (.camelCamelCamelPricePage, .camelCamelCamelPricePage): return true
      case (.qnaAllQuestionsClick, .qnaAllQuestionsClick): return true
      case (.expertReview, .expertReview): return true
      case (.retailer, .retailer): return true
      case (.photo, .photo): return true
      case (.relatedProduct, .relatedProduct): return true
      case (.richEntityHeaderLink, .richEntityHeaderLink): return true
      case (.richEntitySocialProfile, .richEntitySocialProfile): return true
      case (.richEntityFact, .richEntityFact): return true
      case (.richEntityInlineLink, .richEntityInlineLink): return true
      case (.richEntityRelatedSearchClick, .richEntityRelatedSearchClick): return true
      case (.richEntityToggleFullSnippet, .richEntityToggleFullSnippet): return true
      case (.richEntityToggleAllFacts, .richEntityToggleAllFacts): return true
      case (.richEntityToggleAllValues, .richEntityToggleAllValues): return true
      case (.richEntityTvEpisodeClick, .richEntityTvEpisodeClick): return true
      case (.richEntityTvEpisodeAllToggle, .richEntityTvEpisodeAllToggle): return true
      case (.twitterStatusClick, .twitterStatusClick): return true
      case (.twitterDisplayUrlClick, .twitterDisplayUrlClick): return true
      case (.twitterProfileUrlClick, .twitterProfileUrlClick): return true
      case (.knowledgeGraphAnswerNodeClick, .knowledgeGraphAnswerNodeClick): return true
      case (.techQnaAttributionClick, .techQnaAttributionClick): return true
      case (.buyingGuideNavigationClick, .buyingGuideNavigationClick): return true
      case (.richCaptionClick, .richCaptionClick): return true
      case (.internalQuery, .internalQuery): return true
      case (.inlineSrpProduct, .inlineSrpProduct): return true
      case (.relatedQnaToggle, .relatedQnaToggle): return true
      case (.relatedQnAActionLink, .relatedQnAActionLink): return true
      case (.purchaseLink, .purchaseLink): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ResultActionType] {
    return [
      .allReviewsClick,
      .camelCamelCamelPricePage,
      .qnaAllQuestionsClick,
      .expertReview,
      .retailer,
      .photo,
      .relatedProduct,
      .richEntityHeaderLink,
      .richEntitySocialProfile,
      .richEntityFact,
      .richEntityInlineLink,
      .richEntityRelatedSearchClick,
      .richEntityToggleFullSnippet,
      .richEntityToggleAllFacts,
      .richEntityToggleAllValues,
      .richEntityTvEpisodeClick,
      .richEntityTvEpisodeAllToggle,
      .twitterStatusClick,
      .twitterDisplayUrlClick,
      .twitterProfileUrlClick,
      .knowledgeGraphAnswerNodeClick,
      .techQnaAttributionClick,
      .buyingGuideNavigationClick,
      .richCaptionClick,
      .internalQuery,
      .inlineSrpProduct,
      .relatedQnaToggle,
      .relatedQnAActionLink,
      .purchaseLink,
    ]
  }
}

/// This enum needs to be keep in sync with
/// fedsearch/request/interaction_logger_request.go
/// 
/// and need to add to fedsearch/mixer/packer.go
/// to start collecting the data.
/// 
/// Keep this enum in sync with InteractionType in file
/// neeva/logs/avro_schemas/interaction/interaction_log_v2_entry.avsc
public enum InteractionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The user sees the item for a minimum number of seconds.
  /// DEPRECATED
  /// Removed from client code 2020-09-24
  /// webui: 0.2.144
  /// nativeui: 0.7.2
  case view
  /// The user sees an item for a longer period of time.
  /// DEPRECATED
  /// Removed from client code 2020-09-24
  /// webui: 0.2.144
  /// nativeui: 0.7.2
  case longView
  /// The user hovers over the item.
  /// DEPRECATED
  /// Removed from client code 2020-09-24
  /// webui: 0.2.144
  /// nativeui: 0.7.2
  case hover
  /// The user clicks on the item.
  case click
  /// The user clicks on like
  case like
  /// The user click undo like
  case undoLike
  /// The user clicked on hide
  case hide
  /// The user clicked on Undo hide
  case undoHide
  /// The user clicked on hide always
  case hideAlways
  /// The user created a space
  case createSpace
  /// The user added to space
  case addToSpace
  /// The user copied to space
  case copyToSpace
  /// The user removed it from space
  case removeFromSpace
  /// The user deleted the snapshot from the space entity
  case deleteSnapshotFromSpaceEntity
  /// The user edited the space entity
  case editSpaceEntity
  /// The user renamed the space entity
  case renameSpaceEntity
  /// The user shared space
  case shareSpace
  /// The user renamed space
  case renameSpace
  /// The user edited space
  case editSpace
  /// The user deleted space
  case deleteSpace
  /// The user left the space
  case leaveSpace
  /// The user accepted a space sharing invite
  case acceptSpaceInvite
  /// The user declined a space sharing invite
  case declineSpaceInvite
  /// The user clicked to view an original snapshot page
  case viewOriginalSnapshotPage
  /// The user added comment to space
  case addCommentToSpace
  /// The user edited comment on space
  case editCommentOnSpace
  /// The user deleted comment from space
  case deleteCommentFromSpace
  /// The user added a public acl to a space
  case addSpacePublicAcl
  /// The user deleted a public acl from a space
  case deleteSpacePublicAcl
  /// The user previewed it
  case preview
  /// The user navigated left on a preview
  case previewNavLeft
  /// The user navigated right on a preview
  case previewNavRight
  /// The user exited a preview
  case previewClose
  /// User scrolled carousel left
  case leftScrollCarousel
  /// User scrolled carousel right
  case rightScrollCarousel
  /// The user clicked on search Suggest
  case suggestClick
  /// The user filled from the search Suggest
  case suggestFill
  /// The user focused on the suggestion
  case suggestFocus
  /// The user viewed the suggestion
  case suggestView
  /// Typed query matches suggestion
  case suggestMatchedTyped
  /// User clicked to DuckDuckGo search
  case duckDuckGoClick
  /// User clicked to Google search
  case googleSearchClick
  /// User clicked to Bing search
  case bingSearchClick
  /// User clicked on corpus filter
  case corpusFilterClick
  /// User clicked on show more/less to see more/less results
  case oneBoxClick
  /// Click on result group.
  case resultGroupClick
  /// Click on universal results like image, video
  case universalClick
  /// The user clicks on follow
  case follow
  /// The user clicks on unfollow
  case unfollow
  /// The user clicks on the geolocation prompt
  case geolocationClick
  /// Page view interaction type
  case pageView
  /// Open all links contained in Space
  case spaceOpenAllLinksClick
  /// Click to start reorder operation in Space
  case spaceStartReorderClick
  /// The user click on item that is on RHS
  case rhsClick
  /// The User clicked on show more/less on RHS item to see more/less results
  case rhsOneBoxClick
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "View": self = .view
      case "LongView": self = .longView
      case "Hover": self = .hover
      case "Click": self = .click
      case "Like": self = .like
      case "UndoLike": self = .undoLike
      case "Hide": self = .hide
      case "UndoHide": self = .undoHide
      case "HideAlways": self = .hideAlways
      case "CreateSpace": self = .createSpace
      case "AddToSpace": self = .addToSpace
      case "CopyToSpace": self = .copyToSpace
      case "RemoveFromSpace": self = .removeFromSpace
      case "DeleteSnapshotFromSpaceEntity": self = .deleteSnapshotFromSpaceEntity
      case "EditSpaceEntity": self = .editSpaceEntity
      case "RenameSpaceEntity": self = .renameSpaceEntity
      case "ShareSpace": self = .shareSpace
      case "RenameSpace": self = .renameSpace
      case "EditSpace": self = .editSpace
      case "DeleteSpace": self = .deleteSpace
      case "LeaveSpace": self = .leaveSpace
      case "AcceptSpaceInvite": self = .acceptSpaceInvite
      case "DeclineSpaceInvite": self = .declineSpaceInvite
      case "ViewOriginalSnapshotPage": self = .viewOriginalSnapshotPage
      case "AddCommentToSpace": self = .addCommentToSpace
      case "EditCommentOnSpace": self = .editCommentOnSpace
      case "DeleteCommentFromSpace": self = .deleteCommentFromSpace
      case "AddSpacePublicAcl": self = .addSpacePublicAcl
      case "DeleteSpacePublicAcl": self = .deleteSpacePublicAcl
      case "Preview": self = .preview
      case "PreviewNavLeft": self = .previewNavLeft
      case "PreviewNavRight": self = .previewNavRight
      case "PreviewClose": self = .previewClose
      case "LeftScrollCarousel": self = .leftScrollCarousel
      case "RightScrollCarousel": self = .rightScrollCarousel
      case "SuggestClick": self = .suggestClick
      case "SuggestFill": self = .suggestFill
      case "SuggestFocus": self = .suggestFocus
      case "SuggestView": self = .suggestView
      case "SuggestMatchedTyped": self = .suggestMatchedTyped
      case "DuckDuckGoClick": self = .duckDuckGoClick
      case "GoogleSearchClick": self = .googleSearchClick
      case "BingSearchClick": self = .bingSearchClick
      case "CorpusFilterClick": self = .corpusFilterClick
      case "OneBoxClick": self = .oneBoxClick
      case "ResultGroupClick": self = .resultGroupClick
      case "UniversalClick": self = .universalClick
      case "Follow": self = .follow
      case "Unfollow": self = .unfollow
      case "GeolocationClick": self = .geolocationClick
      case "PageView": self = .pageView
      case "SpaceOpenAllLinksClick": self = .spaceOpenAllLinksClick
      case "SpaceStartReorderClick": self = .spaceStartReorderClick
      case "RhsClick": self = .rhsClick
      case "RhsOneBoxClick": self = .rhsOneBoxClick
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .view: return "View"
      case .longView: return "LongView"
      case .hover: return "Hover"
      case .click: return "Click"
      case .like: return "Like"
      case .undoLike: return "UndoLike"
      case .hide: return "Hide"
      case .undoHide: return "UndoHide"
      case .hideAlways: return "HideAlways"
      case .createSpace: return "CreateSpace"
      case .addToSpace: return "AddToSpace"
      case .copyToSpace: return "CopyToSpace"
      case .removeFromSpace: return "RemoveFromSpace"
      case .deleteSnapshotFromSpaceEntity: return "DeleteSnapshotFromSpaceEntity"
      case .editSpaceEntity: return "EditSpaceEntity"
      case .renameSpaceEntity: return "RenameSpaceEntity"
      case .shareSpace: return "ShareSpace"
      case .renameSpace: return "RenameSpace"
      case .editSpace: return "EditSpace"
      case .deleteSpace: return "DeleteSpace"
      case .leaveSpace: return "LeaveSpace"
      case .acceptSpaceInvite: return "AcceptSpaceInvite"
      case .declineSpaceInvite: return "DeclineSpaceInvite"
      case .viewOriginalSnapshotPage: return "ViewOriginalSnapshotPage"
      case .addCommentToSpace: return "AddCommentToSpace"
      case .editCommentOnSpace: return "EditCommentOnSpace"
      case .deleteCommentFromSpace: return "DeleteCommentFromSpace"
      case .addSpacePublicAcl: return "AddSpacePublicAcl"
      case .deleteSpacePublicAcl: return "DeleteSpacePublicAcl"
      case .preview: return "Preview"
      case .previewNavLeft: return "PreviewNavLeft"
      case .previewNavRight: return "PreviewNavRight"
      case .previewClose: return "PreviewClose"
      case .leftScrollCarousel: return "LeftScrollCarousel"
      case .rightScrollCarousel: return "RightScrollCarousel"
      case .suggestClick: return "SuggestClick"
      case .suggestFill: return "SuggestFill"
      case .suggestFocus: return "SuggestFocus"
      case .suggestView: return "SuggestView"
      case .suggestMatchedTyped: return "SuggestMatchedTyped"
      case .duckDuckGoClick: return "DuckDuckGoClick"
      case .googleSearchClick: return "GoogleSearchClick"
      case .bingSearchClick: return "BingSearchClick"
      case .corpusFilterClick: return "CorpusFilterClick"
      case .oneBoxClick: return "OneBoxClick"
      case .resultGroupClick: return "ResultGroupClick"
      case .universalClick: return "UniversalClick"
      case .follow: return "Follow"
      case .unfollow: return "Unfollow"
      case .geolocationClick: return "GeolocationClick"
      case .pageView: return "PageView"
      case .spaceOpenAllLinksClick: return "SpaceOpenAllLinksClick"
      case .spaceStartReorderClick: return "SpaceStartReorderClick"
      case .rhsClick: return "RhsClick"
      case .rhsOneBoxClick: return "RhsOneBoxClick"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: InteractionType, rhs: InteractionType) -> Bool {
    switch (lhs, rhs) {
      case (.view, .view): return true
      case (.longView, .longView): return true
      case (.hover, .hover): return true
      case (.click, .click): return true
      case (.like, .like): return true
      case (.undoLike, .undoLike): return true
      case (.hide, .hide): return true
      case (.undoHide, .undoHide): return true
      case (.hideAlways, .hideAlways): return true
      case (.createSpace, .createSpace): return true
      case (.addToSpace, .addToSpace): return true
      case (.copyToSpace, .copyToSpace): return true
      case (.removeFromSpace, .removeFromSpace): return true
      case (.deleteSnapshotFromSpaceEntity, .deleteSnapshotFromSpaceEntity): return true
      case (.editSpaceEntity, .editSpaceEntity): return true
      case (.renameSpaceEntity, .renameSpaceEntity): return true
      case (.shareSpace, .shareSpace): return true
      case (.renameSpace, .renameSpace): return true
      case (.editSpace, .editSpace): return true
      case (.deleteSpace, .deleteSpace): return true
      case (.leaveSpace, .leaveSpace): return true
      case (.acceptSpaceInvite, .acceptSpaceInvite): return true
      case (.declineSpaceInvite, .declineSpaceInvite): return true
      case (.viewOriginalSnapshotPage, .viewOriginalSnapshotPage): return true
      case (.addCommentToSpace, .addCommentToSpace): return true
      case (.editCommentOnSpace, .editCommentOnSpace): return true
      case (.deleteCommentFromSpace, .deleteCommentFromSpace): return true
      case (.addSpacePublicAcl, .addSpacePublicAcl): return true
      case (.deleteSpacePublicAcl, .deleteSpacePublicAcl): return true
      case (.preview, .preview): return true
      case (.previewNavLeft, .previewNavLeft): return true
      case (.previewNavRight, .previewNavRight): return true
      case (.previewClose, .previewClose): return true
      case (.leftScrollCarousel, .leftScrollCarousel): return true
      case (.rightScrollCarousel, .rightScrollCarousel): return true
      case (.suggestClick, .suggestClick): return true
      case (.suggestFill, .suggestFill): return true
      case (.suggestFocus, .suggestFocus): return true
      case (.suggestView, .suggestView): return true
      case (.suggestMatchedTyped, .suggestMatchedTyped): return true
      case (.duckDuckGoClick, .duckDuckGoClick): return true
      case (.googleSearchClick, .googleSearchClick): return true
      case (.bingSearchClick, .bingSearchClick): return true
      case (.corpusFilterClick, .corpusFilterClick): return true
      case (.oneBoxClick, .oneBoxClick): return true
      case (.resultGroupClick, .resultGroupClick): return true
      case (.universalClick, .universalClick): return true
      case (.follow, .follow): return true
      case (.unfollow, .unfollow): return true
      case (.geolocationClick, .geolocationClick): return true
      case (.pageView, .pageView): return true
      case (.spaceOpenAllLinksClick, .spaceOpenAllLinksClick): return true
      case (.spaceStartReorderClick, .spaceStartReorderClick): return true
      case (.rhsClick, .rhsClick): return true
      case (.rhsOneBoxClick, .rhsOneBoxClick): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [InteractionType] {
    return [
      .view,
      .longView,
      .hover,
      .click,
      .like,
      .undoLike,
      .hide,
      .undoHide,
      .hideAlways,
      .createSpace,
      .addToSpace,
      .copyToSpace,
      .removeFromSpace,
      .deleteSnapshotFromSpaceEntity,
      .editSpaceEntity,
      .renameSpaceEntity,
      .shareSpace,
      .renameSpace,
      .editSpace,
      .deleteSpace,
      .leaveSpace,
      .acceptSpaceInvite,
      .declineSpaceInvite,
      .viewOriginalSnapshotPage,
      .addCommentToSpace,
      .editCommentOnSpace,
      .deleteCommentFromSpace,
      .addSpacePublicAcl,
      .deleteSpacePublicAcl,
      .preview,
      .previewNavLeft,
      .previewNavRight,
      .previewClose,
      .leftScrollCarousel,
      .rightScrollCarousel,
      .suggestClick,
      .suggestFill,
      .suggestFocus,
      .suggestView,
      .suggestMatchedTyped,
      .duckDuckGoClick,
      .googleSearchClick,
      .bingSearchClick,
      .corpusFilterClick,
      .oneBoxClick,
      .resultGroupClick,
      .universalClick,
      .follow,
      .unfollow,
      .geolocationClick,
      .pageView,
      .spaceOpenAllLinksClick,
      .spaceStartReorderClick,
      .rhsClick,
      .rhsOneBoxClick,
    ]
  }
}

/// Page attributes
public struct PageEventAttributes: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - pageId
  ///   - previousPageId
  ///   - corpusFilter
  ///   - corpusCount
  ///   - suggestClickMetadata
  ///   - corpusType
  public init(pageId: Swift.Optional<String?> = nil, previousPageId: Swift.Optional<String?> = nil, corpusFilter: Swift.Optional<CorpusFilterTransition?> = nil, corpusCount: Swift.Optional<Int?> = nil, suggestClickMetadata: Swift.Optional<SuggestClickMetadata?> = nil, corpusType: Swift.Optional<CorpusType?> = nil) {
    graphQLMap = ["pageID": pageId, "previousPageID": previousPageId, "corpusFilter": corpusFilter, "corpusCount": corpusCount, "suggestClickMetadata": suggestClickMetadata, "corpusType": corpusType]
  }

  public var pageId: Swift.Optional<String?> {
    get {
      return graphQLMap["pageID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "pageID")
    }
  }

  public var previousPageId: Swift.Optional<String?> {
    get {
      return graphQLMap["previousPageID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "previousPageID")
    }
  }

  public var corpusFilter: Swift.Optional<CorpusFilterTransition?> {
    get {
      return graphQLMap["corpusFilter"] as? Swift.Optional<CorpusFilterTransition?> ?? Swift.Optional<CorpusFilterTransition?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "corpusFilter")
    }
  }

  public var corpusCount: Swift.Optional<Int?> {
    get {
      return graphQLMap["corpusCount"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "corpusCount")
    }
  }

  public var suggestClickMetadata: Swift.Optional<SuggestClickMetadata?> {
    get {
      return graphQLMap["suggestClickMetadata"] as? Swift.Optional<SuggestClickMetadata?> ?? Swift.Optional<SuggestClickMetadata?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "suggestClickMetadata")
    }
  }

  public var corpusType: Swift.Optional<CorpusType?> {
    get {
      return graphQLMap["corpusType"] as? Swift.Optional<CorpusType?> ?? Swift.Optional<CorpusType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "corpusType")
    }
  }
}

public struct CorpusFilterTransition: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - to
  ///   - from
  public init(to: Swift.Optional<String?> = nil, from: Swift.Optional<String?> = nil) {
    graphQLMap = ["to": to, "from": from]
  }

  public var to: Swift.Optional<String?> {
    get {
      return graphQLMap["to"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "to")
    }
  }

  public var from: Swift.Optional<String?> {
    get {
      return graphQLMap["from"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "from")
    }
  }
}

public struct SuggestClickMetadata: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - clickedSuggestion
  ///   - shownSuggestions
  ///   - suggestionEventId
  public init(clickedSuggestion: Swift.Optional<SuggestionMetadata?> = nil, shownSuggestions: Swift.Optional<[SuggestionMetadata]?> = nil, suggestionEventId: Swift.Optional<String?> = nil) {
    graphQLMap = ["clickedSuggestion": clickedSuggestion, "shownSuggestions": shownSuggestions, "suggestionEventID": suggestionEventId]
  }

  public var clickedSuggestion: Swift.Optional<SuggestionMetadata?> {
    get {
      return graphQLMap["clickedSuggestion"] as? Swift.Optional<SuggestionMetadata?> ?? Swift.Optional<SuggestionMetadata?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "clickedSuggestion")
    }
  }

  public var shownSuggestions: Swift.Optional<[SuggestionMetadata]?> {
    get {
      return graphQLMap["shownSuggestions"] as? Swift.Optional<[SuggestionMetadata]?> ?? Swift.Optional<[SuggestionMetadata]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "shownSuggestions")
    }
  }

  public var suggestionEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["suggestionEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "suggestionEventID")
    }
  }
}

public struct SuggestionMetadata: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - suggestionTitle
  ///   - docId
  ///   - rank
  ///   - source
  ///   - type
  public init(suggestionTitle: Swift.Optional<String?> = nil, docId: Swift.Optional<String?> = nil, rank: Swift.Optional<Int?> = nil, source: Swift.Optional<String?> = nil, type: Swift.Optional<String?> = nil) {
    graphQLMap = ["suggestionTitle": suggestionTitle, "docID": docId, "rank": rank, "source": source, "type": type]
  }

  public var suggestionTitle: Swift.Optional<String?> {
    get {
      return graphQLMap["suggestionTitle"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "suggestionTitle")
    }
  }

  public var docId: Swift.Optional<String?> {
    get {
      return graphQLMap["docID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "docID")
    }
  }

  public var rank: Swift.Optional<Int?> {
    get {
      return graphQLMap["rank"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rank")
    }
  }

  public var source: Swift.Optional<String?> {
    get {
      return graphQLMap["source"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "source")
    }
  }

  public var type: Swift.Optional<String?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }
}

public enum CorpusType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case personal
  case `public`
  case image
  case news
  case maps
  case recipes
  case shopping
  case video
  case all
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Personal": self = .personal
      case "Public": self = .public
      case "Image": self = .image
      case "News": self = .news
      case "Maps": self = .maps
      case "Recipes": self = .recipes
      case "Shopping": self = .shopping
      case "Video": self = .video
      case "All": self = .all
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .personal: return "Personal"
      case .public: return "Public"
      case .image: return "Image"
      case .news: return "News"
      case .maps: return "Maps"
      case .recipes: return "Recipes"
      case .shopping: return "Shopping"
      case .video: return "Video"
      case .all: return "All"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CorpusType, rhs: CorpusType) -> Bool {
    switch (lhs, rhs) {
      case (.personal, .personal): return true
      case (.public, .public): return true
      case (.image, .image): return true
      case (.news, .news): return true
      case (.maps, .maps): return true
      case (.recipes, .recipes): return true
      case (.shopping, .shopping): return true
      case (.video, .video): return true
      case (.all, .all): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [CorpusType] {
    return [
      .personal,
      .public,
      .image,
      .news,
      .maps,
      .recipes,
      .shopping,
      .video,
      .all,
    ]
  }
}

/// Result Group attributes
/// TODO: Move this to logging context
public struct ResultGroupAttributes: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - resultGroupAction
  public init(resultGroupAction: Swift.Optional<ResultGroupActionType?> = nil) {
    graphQLMap = ["resultGroupAction": resultGroupAction]
  }

  public var resultGroupAction: Swift.Optional<ResultGroupActionType?> {
    get {
      return graphQLMap["resultGroupAction"] as? Swift.Optional<ResultGroupActionType?> ?? Swift.Optional<ResultGroupActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultGroupAction")
    }
  }
}

/// Input type for v3 ClientLog.interactionV3Event mutation.
/// 
/// This is the preferred mechanism for logging an interaction that happens in a
/// search results page (SRP) context. The concepts and design behind how
/// interactions are recorded in the design doc:
/// 
/// https://paper.dropbox.com/doc/Logging-V3-Page-structure--A7Q0Gpx7oVh1vflhuaIBsHQfAg-4RsxGgmgnFiaM5Rg72YjO
public struct InteractionV3EventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - loggingContexts: Array of all logging contexts
  ///   - action: The action the user took.
  ///   - requestEventId: DocId of the request for which the event being recorded
  public init(loggingContexts: Swift.Optional<[LoggingContext]?> = nil, action: Swift.Optional<InteractionV3ActionInput?> = nil, requestEventId: Swift.Optional<String?> = nil) {
    graphQLMap = ["loggingContexts": loggingContexts, "action": action, "requestEventID": requestEventId]
  }

  /// Array of all logging contexts
  public var loggingContexts: Swift.Optional<[LoggingContext]?> {
    get {
      return graphQLMap["loggingContexts"] as? Swift.Optional<[LoggingContext]?> ?? Swift.Optional<[LoggingContext]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "loggingContexts")
    }
  }

  /// The action the user took.
  public var action: Swift.Optional<InteractionV3ActionInput?> {
    get {
      return graphQLMap["action"] as? Swift.Optional<InteractionV3ActionInput?> ?? Swift.Optional<InteractionV3ActionInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "action")
    }
  }

  /// DocId of the request for which the event being recorded
  public var requestEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["requestEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestEventID")
    }
  }
}

/// This defines the structure of an action for the interactions v3.
public struct InteractionV3ActionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - actionType: The type of the action.
  ///   - category: The target category of the action. This should have the same taxonomy as
  /// the category for LoggingContext.
  ///   - element: What element within the group/result/etc. that the action took place. For
  /// example, this may be an ExpertReview or Retailer within a shopping result.
  /// 
  /// This is a relatively free-form field. Please add the things that make the most
  /// sense for _your particular_ use case.
  ///   - elementAction: Optional. The action taken on the Element. If the Element is Carousel, then
  /// the ElementAction may be 'ScrollLeft' or 'ScrollRight'
  /// 
  /// Only used in cases when you have multiple actions that can happen on the
  /// same Element.
  public init(actionType: Swift.Optional<InteractionV3Type?> = nil, category: Swift.Optional<InteractionV3Category?> = nil, element: Swift.Optional<String?> = nil, elementAction: Swift.Optional<String?> = nil) {
    graphQLMap = ["actionType": actionType, "category": category, "element": element, "elementAction": elementAction]
  }

  /// The type of the action.
  public var actionType: Swift.Optional<InteractionV3Type?> {
    get {
      return graphQLMap["actionType"] as? Swift.Optional<InteractionV3Type?> ?? Swift.Optional<InteractionV3Type?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "actionType")
    }
  }

  /// The target category of the action. This should have the same taxonomy as
  /// the category for LoggingContext.
  public var category: Swift.Optional<InteractionV3Category?> {
    get {
      return graphQLMap["category"] as? Swift.Optional<InteractionV3Category?> ?? Swift.Optional<InteractionV3Category?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  /// What element within the group/result/etc. that the action took place. For
  /// example, this may be an ExpertReview or Retailer within a shopping result.
  /// 
  /// This is a relatively free-form field. Please add the things that make the most
  /// sense for _your particular_ use case.
  public var element: Swift.Optional<String?> {
    get {
      return graphQLMap["element"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "element")
    }
  }

  /// Optional. The action taken on the Element. If the Element is Carousel, then
  /// the ElementAction may be 'ScrollLeft' or 'ScrollRight'
  /// 
  /// Only used in cases when you have multiple actions that can happen on the
  /// same Element.
  public var elementAction: Swift.Optional<String?> {
    get {
      return graphQLMap["elementAction"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "elementAction")
    }
  }
}

/// The collection of action types for the v3 interactions table.
/// 
/// Be VERY CAREFUL about extending the action types here. In general, we want
/// to have a very limited number of action types. If you need more information
/// about the context of an action, consider using Element, ElementAction, or
/// the Attributes table.
/// 
/// PLEASE KEEP IN SYNC with //schemas/constants/interaction_type.go.
public enum InteractionV3Type: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Click covers all outbound clicks, i.e. anything that takes you outside of
  /// neeva.
  case click
  /// View represents a view, according to the definition we've set (e.g. may or
  /// may not be delayed).
  case view
  /// InternalClick represents a non-outbound click, and involves
  /// the user interacting with some semantically meaningful part of a widget that
  /// does not cause the user to leave the search context. Usually this is
  /// something like navigating a carousel, showing more information, or seeing a
  /// preview. Excludes MetaClicks.
  case internalClick
  /// MetaClick represents a non-outbound click, and involves the
  /// user interacting with a search element that changes the user’s relationship
  /// to that element. This can be hide, follow, add to space, etc. Unlike an
  /// InternalClick, a MetaClick does not involve the user interacting with the
  /// element in a way that provides more information to the user.
  case metaClick
  /// Refinement is an interaction that initiates another, related search context,
  /// i.e. by applying a corpus filter or opening a related search.
  case refinement
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Click": self = .click
      case "View": self = .view
      case "InternalClick": self = .internalClick
      case "MetaClick": self = .metaClick
      case "Refinement": self = .refinement
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .click: return "Click"
      case .view: return "View"
      case .internalClick: return "InternalClick"
      case .metaClick: return "MetaClick"
      case .refinement: return "Refinement"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: InteractionV3Type, rhs: InteractionV3Type) -> Bool {
    switch (lhs, rhs) {
      case (.click, .click): return true
      case (.view, .view): return true
      case (.internalClick, .internalClick): return true
      case (.metaClick, .metaClick): return true
      case (.refinement, .refinement): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [InteractionV3Type] {
    return [
      .click,
      .view,
      .internalClick,
      .metaClick,
      .refinement,
    ]
  }
}

/// InteractionV3Category specifies the type of the item in the log tree hierarchy.
/// The log tree can have have N number of entries, but these are the ones
/// that have IDs associated.
/// 
/// PLEASE KEEP IN SYNC with //schemas/constants/category.go
public enum InteractionV3Category: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Represents a page, such as a search results page or a space page.
  case page
  /// Represents a group of results or containers. This is synonymous with "result
  /// group".
  case group
  /// Represents a container of results, such as a news list or video carousel.
  case container
  /// Represents a single result. The result can be simple (a web link) or complex
  /// (a rich entity), but this is the terminal category to which an action can
  /// belong.
  case result
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "page": self = .page
      case "group": self = .group
      case "container": self = .container
      case "result": self = .result
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .page: return "page"
      case .group: return "group"
      case .container: return "container"
      case .result: return "result"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: InteractionV3Category, rhs: InteractionV3Category) -> Bool {
    switch (lhs, rhs) {
      case (.page, .page): return true
      case (.group, .group): return true
      case (.container, .container): return true
      case (.result, .result): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [InteractionV3Category] {
    return [
      .page,
      .group,
      .container,
      .result,
    ]
  }
}

/// Search Perf related data collected from client
public struct SearchPerfEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - parentEventId: Parent event ID of the page.
  /// This is a event of graphqql request fied to render the measured view
  ///   - appState: State of the app at the time of the event
  ///   - effectiveNetworkType: Type of network predicted by browser based (supported in chrome)
  /// 
  /// Doc: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
  ///   - rttMs: RTT of the recent connection
  ///   - userActionTimeMs: Use action time in ms since start of the document
  /// This is valid only when inAppTransition is true
  ///   - queryRequestTimeMs: Query start time, since start of the document 
  ///   - queryResponseTimeMs: Query response received, since start of the document
  ///   - resultRenderTimeMs: Result is rendered on the browser, since start of the document
  ///   - criticalPathResourcePerfEntries: Detailed critical path resources of critical path resources as JSON
  ///   - appBootstrapTimeMs: App bootstrapped, just before react render
  ///   - appLoadingTimeMs: App marked as loading time in Ms
  ///   - loggedInTimeMs: App logged in time
  ///   - customMarkers: Custom markers added by neeva app sent as JSON
  public init(parentEventId: Swift.Optional<String?> = nil, appState: Swift.Optional<AppState?> = nil, effectiveNetworkType: Swift.Optional<String?> = nil, rttMs: Swift.Optional<Int?> = nil, userActionTimeMs: Swift.Optional<Double?> = nil, queryRequestTimeMs: Swift.Optional<Double?> = nil, queryResponseTimeMs: Swift.Optional<Double?> = nil, resultRenderTimeMs: Swift.Optional<Double?> = nil, criticalPathResourcePerfEntries: Swift.Optional<String?> = nil, appBootstrapTimeMs: Swift.Optional<Double?> = nil, appLoadingTimeMs: Swift.Optional<Double?> = nil, loggedInTimeMs: Swift.Optional<Double?> = nil, customMarkers: Swift.Optional<String?> = nil) {
    graphQLMap = ["parentEventID": parentEventId, "appState": appState, "effectiveNetworkType": effectiveNetworkType, "rttMs": rttMs, "userActionTimeMs": userActionTimeMs, "queryRequestTimeMs": queryRequestTimeMs, "queryResponseTimeMs": queryResponseTimeMs, "resultRenderTimeMs": resultRenderTimeMs, "criticalPathResourcePerfEntries": criticalPathResourcePerfEntries, "appBootstrapTimeMs": appBootstrapTimeMs, "appLoadingTimeMs": appLoadingTimeMs, "loggedInTimeMs": loggedInTimeMs, "customMarkers": customMarkers]
  }

  /// Parent event ID of the page.
  /// This is a event of graphqql request fied to render the measured view
  public var parentEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["parentEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "parentEventID")
    }
  }

  /// State of the app at the time of the event
  public var appState: Swift.Optional<AppState?> {
    get {
      return graphQLMap["appState"] as? Swift.Optional<AppState?> ?? Swift.Optional<AppState?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appState")
    }
  }

  /// Type of network predicted by browser based (supported in chrome)
  /// 
  /// Doc: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
  public var effectiveNetworkType: Swift.Optional<String?> {
    get {
      return graphQLMap["effectiveNetworkType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "effectiveNetworkType")
    }
  }

  /// RTT of the recent connection
  public var rttMs: Swift.Optional<Int?> {
    get {
      return graphQLMap["rttMs"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rttMs")
    }
  }

  /// Use action time in ms since start of the document
  /// This is valid only when inAppTransition is true
  public var userActionTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["userActionTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userActionTimeMs")
    }
  }

  /// Query start time, since start of the document
  public var queryRequestTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["queryRequestTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "queryRequestTimeMs")
    }
  }

  /// Query response received, since start of the document
  public var queryResponseTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["queryResponseTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "queryResponseTimeMs")
    }
  }

  /// Result is rendered on the browser, since start of the document
  public var resultRenderTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["resultRenderTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultRenderTimeMs")
    }
  }

  /// Detailed critical path resources of critical path resources as JSON
  public var criticalPathResourcePerfEntries: Swift.Optional<String?> {
    get {
      return graphQLMap["criticalPathResourcePerfEntries"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "criticalPathResourcePerfEntries")
    }
  }

  /// App bootstrapped, just before react render
  public var appBootstrapTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["appBootstrapTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appBootstrapTimeMs")
    }
  }

  /// App marked as loading time in Ms
  public var appLoadingTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["appLoadingTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appLoadingTimeMs")
    }
  }

  /// App logged in time
  public var loggedInTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["loggedInTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "loggedInTimeMs")
    }
  }

  /// Custom markers added by neeva app sent as JSON
  public var customMarkers: Swift.Optional<String?> {
    get {
      return graphQLMap["customMarkers"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "customMarkers")
    }
  }
}

public enum AppState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Main app.js was not in cache
  case coldStart
  /// Opposite of ColdStart
  case warmStart
  /// InApp transition
  case inApp
  /// Request is rendered with SSR
  case ssr
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ColdStart": self = .coldStart
      case "WarmStart": self = .warmStart
      case "InApp": self = .inApp
      case "Ssr": self = .ssr
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .coldStart: return "ColdStart"
      case .warmStart: return "WarmStart"
      case .inApp: return "InApp"
      case .ssr: return "Ssr"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: AppState, rhs: AppState) -> Bool {
    switch (lhs, rhs) {
      case (.coldStart, .coldStart): return true
      case (.warmStart, .warmStart): return true
      case (.inApp, .inApp): return true
      case (.ssr, .ssr): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [AppState] {
    return [
      .coldStart,
      .warmStart,
      .inApp,
      .ssr,
    ]
  }
}

/// Suggest latency logs,
/// all times are origin of the page (instance at which page was initiated)
public struct SuggestPerfEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - eventId: event of suggest request
  ///   - requestResourceTiming: JSON blob of suggest request from browser
  ///   - requestStartTimeMs: Suggest request start
  ///   - responseStartTimeMs: Suggest response start receiving
  ///   - responseEndTimeMs: Suggest response received, last byte
  ///   - renderTimeMs: Suggest response render time
  public init(eventId: Swift.Optional<String?> = nil, requestResourceTiming: Swift.Optional<String?> = nil, requestStartTimeMs: Swift.Optional<Double?> = nil, responseStartTimeMs: Swift.Optional<Double?> = nil, responseEndTimeMs: Swift.Optional<Double?> = nil, renderTimeMs: Swift.Optional<Double?> = nil) {
    graphQLMap = ["eventID": eventId, "requestResourceTiming": requestResourceTiming, "requestStartTimeMs": requestStartTimeMs, "responseStartTimeMs": responseStartTimeMs, "responseEndTimeMs": responseEndTimeMs, "renderTimeMs": renderTimeMs]
  }

  /// event of suggest request
  public var eventId: Swift.Optional<String?> {
    get {
      return graphQLMap["eventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eventID")
    }
  }

  /// JSON blob of suggest request from browser
  public var requestResourceTiming: Swift.Optional<String?> {
    get {
      return graphQLMap["requestResourceTiming"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestResourceTiming")
    }
  }

  /// Suggest request start
  public var requestStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["requestStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestStartTimeMs")
    }
  }

  /// Suggest response start receiving
  public var responseStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["responseStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "responseStartTimeMs")
    }
  }

  /// Suggest response received, last byte
  public var responseEndTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["responseEndTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "responseEndTimeMs")
    }
  }

  /// Suggest response render time
  public var renderTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["renderTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "renderTimeMs")
    }
  }
}

public struct PerfTraceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - traceGroupId: The group ID of the trace. This can be used to join multiple, interacting
  /// traces that may track things happening in parallel.
  ///   - type: The type of the perf trace. This is an identifier like 'search' or
  /// 'bootstrap'. We are specifically not providing an exact contract for trace
  /// types, since we want to allow flexibility on the client.
  ///   - traceStartTimeMs: The wallclock start time of the trace, as measured by the client.
  ///   - requestEventId: Request event ID of the page.
  /// This is a event of graphqql request fired to render the measured view.
  ///   - appState: State of the app at the time of the event
  ///   - effectiveNetworkType: Type of network predicted by browser based (supported in chrome and in
  /// React Native).
  /// 
  /// Doc: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
  ///   - events: The events in the trace. A trace is an ordered collection of perf events
  /// that are all related in some way. A single action (such as loading the app)
  /// may result in multiple traces, some with shared events, depending on what
  /// view of the trace you're looking for.
  ///   - status: The status of the perf trace.
  public init(traceGroupId: Swift.Optional<String?> = nil, type: Swift.Optional<String?> = nil, traceStartTimeMs: Swift.Optional<Double?> = nil, requestEventId: Swift.Optional<String?> = nil, appState: Swift.Optional<AppState?> = nil, effectiveNetworkType: Swift.Optional<String?> = nil, events: Swift.Optional<[PerfEvent]?> = nil, status: Swift.Optional<PerfTraceStatus?> = nil) {
    graphQLMap = ["traceGroupID": traceGroupId, "type": type, "traceStartTimeMs": traceStartTimeMs, "requestEventID": requestEventId, "appState": appState, "effectiveNetworkType": effectiveNetworkType, "events": events, "status": status]
  }

  /// The group ID of the trace. This can be used to join multiple, interacting
  /// traces that may track things happening in parallel.
  public var traceGroupId: Swift.Optional<String?> {
    get {
      return graphQLMap["traceGroupID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "traceGroupID")
    }
  }

  /// The type of the perf trace. This is an identifier like 'search' or
  /// 'bootstrap'. We are specifically not providing an exact contract for trace
  /// types, since we want to allow flexibility on the client.
  public var type: Swift.Optional<String?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// The wallclock start time of the trace, as measured by the client.
  public var traceStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["traceStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "traceStartTimeMs")
    }
  }

  /// Request event ID of the page.
  /// This is a event of graphqql request fired to render the measured view.
  public var requestEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["requestEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestEventID")
    }
  }

  /// State of the app at the time of the event
  public var appState: Swift.Optional<AppState?> {
    get {
      return graphQLMap["appState"] as? Swift.Optional<AppState?> ?? Swift.Optional<AppState?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appState")
    }
  }

  /// Type of network predicted by browser based (supported in chrome and in
  /// React Native).
  /// 
  /// Doc: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
  public var effectiveNetworkType: Swift.Optional<String?> {
    get {
      return graphQLMap["effectiveNetworkType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "effectiveNetworkType")
    }
  }

  /// The events in the trace. A trace is an ordered collection of perf events
  /// that are all related in some way. A single action (such as loading the app)
  /// may result in multiple traces, some with shared events, depending on what
  /// view of the trace you're looking for.
  public var events: Swift.Optional<[PerfEvent]?> {
    get {
      return graphQLMap["events"] as? Swift.Optional<[PerfEvent]?> ?? Swift.Optional<[PerfEvent]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "events")
    }
  }

  /// The status of the perf trace.
  public var status: Swift.Optional<PerfTraceStatus?> {
    get {
      return graphQLMap["status"] as? Swift.Optional<PerfTraceStatus?> ?? Swift.Optional<PerfTraceStatus?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }
}

public struct PerfEvent: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - type: The name of perf event type. Perf event types are defined in the client code.
  ///   - elapsedTotalMs: The elapsed time since the beginning of the perf trace. Note that this is
  /// not the absolute timestamp, which can be computed by adding the trace
  /// timestamp to the elapsedMs.
  ///   - elapsedMs: DEPRECATED 2020-04-24
  /// 
  /// Versions:
  /// - iOS: 0.3.6
  /// - web: never used
  /// 
  /// Not using on the BE since it can be derived from elapsedTotalMs.
  public init(type: Swift.Optional<String?> = nil, elapsedTotalMs: Swift.Optional<Double?> = nil, elapsedMs: Swift.Optional<Double?> = nil) {
    graphQLMap = ["type": type, "elapsedTotalMs": elapsedTotalMs, "elapsedMs": elapsedMs]
  }

  /// The name of perf event type. Perf event types are defined in the client code.
  public var type: Swift.Optional<String?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// The elapsed time since the beginning of the perf trace. Note that this is
  /// not the absolute timestamp, which can be computed by adding the trace
  /// timestamp to the elapsedMs.
  public var elapsedTotalMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["elapsedTotalMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "elapsedTotalMs")
    }
  }

  /// DEPRECATED 2020-04-24
  /// 
  /// Versions:
  /// - iOS: 0.3.6
  /// - web: never used
  /// 
  /// Not using on the BE since it can be derived from elapsedTotalMs.
  public var elapsedMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["elapsedMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "elapsedMs")
    }
  }
}

/// The status of a perf trace.
public enum PerfTraceStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The trace did not complete in either a success or a failure state. This can
  /// mean that the perf event is in progress, or that the perf event failed
  /// silently.
  case incomplete
  /// The trace has completed in a success condition; i.e. the query was rendered.
  case complete
  /// The trace has completed in a failed condition; that is, there was some kind
  /// of error.
  case failed
  /// The trace was canceled; that is, some event was triggered that made this
  /// trace invalid.
  case canceled
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Incomplete": self = .incomplete
      case "Complete": self = .complete
      case "Failed": self = .failed
      case "Canceled": self = .canceled
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .incomplete: return "Incomplete"
      case .complete: return "Complete"
      case .failed: return "Failed"
      case .canceled: return "Canceled"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PerfTraceStatus, rhs: PerfTraceStatus) -> Bool {
    switch (lhs, rhs) {
      case (.incomplete, .incomplete): return true
      case (.complete, .complete): return true
      case (.failed, .failed): return true
      case (.canceled, .canceled): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PerfTraceStatus] {
    return [
      .incomplete,
      .complete,
      .failed,
      .canceled,
    ]
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
  ///   - inviteToken
  ///   - screenshot
  public init(feedback: Swift.Optional<String?> = nil, shareResults: Swift.Optional<Bool?> = nil, requestId: Swift.Optional<String?> = nil, geoLocationStatus: Swift.Optional<String?> = nil, source: Swift.Optional<FeedbackSource?> = nil, inviteToken: Swift.Optional<String?> = nil, screenshot: Swift.Optional<String?> = nil) {
    graphQLMap = ["feedback": feedback, "shareResults": shareResults, "requestID": requestId, "geoLocationStatus": geoLocationStatus, "source": source, "inviteToken": inviteToken, "screenshot": screenshot]
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

  public var screenshot: Swift.Optional<String?> {
    get {
      return graphQLMap["screenshot"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "screenshot")
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
  case appLogin
  case appAccountDeletion
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "App": self = .app
      case "ExtensionUninstall": self = .extensionUninstall
      case "AppRegistration": self = .appRegistration
      case "AppOnboarding": self = .appOnboarding
      case "AppLogin": self = .appLogin
      case "AppAccountDeletion": self = .appAccountDeletion
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .app: return "App"
      case .extensionUninstall: return "ExtensionUninstall"
      case .appRegistration: return "AppRegistration"
      case .appOnboarding: return "AppOnboarding"
      case .appLogin: return "AppLogin"
      case .appAccountDeletion: return "AppAccountDeletion"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: FeedbackSource, rhs: FeedbackSource) -> Bool {
    switch (lhs, rhs) {
      case (.app, .app): return true
      case (.extensionUninstall, .extensionUninstall): return true
      case (.appRegistration, .appRegistration): return true
      case (.appOnboarding, .appOnboarding): return true
      case (.appLogin, .appLogin): return true
      case (.appAccountDeletion, .appAccountDeletion): return true
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
      .appLogin,
      .appAccountDeletion,
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

public struct DeleteSpaceResultByURLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - url
  public init(spaceId: String, url: String) {
    graphQLMap = ["spaceID": spaceId, "url": url]
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
  case calculator
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
      case "Calculator": self = .calculator
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
      case .calculator: return "Calculator"
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
      case (.calculator, .calculator): return true
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
      .calculator,
      .unknown,
      .clipboard,
    ]
  }
}

public enum ActiveLensBangType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unknown
  case lens
  case bang
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unknown": self = .unknown
      case "Lens": self = .lens
      case "Bang": self = .bang
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unknown: return "Unknown"
      case .lens: return "Lens"
      case .bang: return "Bang"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ActiveLensBangType, rhs: ActiveLensBangType) -> Bool {
    switch (lhs, rhs) {
      case (.unknown, .unknown): return true
      case (.lens, .lens): return true
      case (.bang, .bang): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ActiveLensBangType] {
    return [
      .unknown,
      .lens,
      .bang,
    ]
  }
}

public final class LogMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation Log($input: ClientLogInput!) {
      log(input: $input)
    }
    """

  public let operationName: String = "Log"

  public let operationIdentifier: String? = "c7cb9ba8d413a3eef416d5daea86742c333d88018f775e607b2feb001faf9a6b"

  public var input: ClientLogInput

  public init(input: ClientLogInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("log", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(log: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "log": log])
    }

    /// Send a log message from the client.
    public var log: Bool {
      get {
        return resultMap["log"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "log")
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
        featureFlags {
          __typename
          id
          value
          intValue
          floatValue
          stringValue
        }
        authProvider
      }
    }
    """

  public let operationName: String = "UserInfo"

  public let operationIdentifier: String? = "22b5377ca74fa3973228367e94473711011abe5520d6312639d6e9f10196002b"

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
          GraphQLField("featureFlags", type: .nonNull(.list(.nonNull(.object(FeatureFlag.selections))))),
          GraphQLField("authProvider", type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, profile: Profile, featureFlags: [FeatureFlag], authProvider: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "profile": profile.resultMap, "featureFlags": featureFlags.map { (value: FeatureFlag) -> ResultMap in value.resultMap }, "authProvider": authProvider])
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

      /// List of feature flags
      public var featureFlags: [FeatureFlag] {
        get {
          return (resultMap["featureFlags"] as! [ResultMap]).map { (value: ResultMap) -> FeatureFlag in FeatureFlag(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: FeatureFlag) -> ResultMap in value.resultMap }, forKey: "featureFlags")
        }
      }

      /// Name of the authenticator provider the user used to authenticate.
      public var authProvider: String? {
        get {
          return resultMap["authProvider"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "authProvider")
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

      public struct FeatureFlag: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["FeatureFlag"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(Int.self))),
            GraphQLField("value", type: .scalar(Bool.self)),
            GraphQLField("intValue", type: .scalar(Int.self)),
            GraphQLField("floatValue", type: .scalar(Double.self)),
            GraphQLField("stringValue", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: Int, value: Bool? = nil, intValue: Int? = nil, floatValue: Double? = nil, stringValue: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "FeatureFlag", "id": id, "value": value, "intValue": intValue, "floatValue": floatValue, "stringValue": stringValue])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The numeric ID of the feature flag.
        public var id: Int {
          get {
            return resultMap["id"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// The boolean value of the feature flag, to be populated if the flag is of
        /// type Boolean.
        public var value: Bool? {
          get {
            return resultMap["value"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "value")
          }
        }

        /// The integer value of the feature flag, to be populated if the flag is of
        /// type Integer.
        public var intValue: Int? {
          get {
            return resultMap["intValue"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "intValue")
          }
        }

        /// The float value of the feature flag, to be populated if the flag is of
        /// type Float.
        public var floatValue: Double? {
          get {
            return resultMap["floatValue"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "floatValue")
          }
        }

        /// The string value of the feature flag, to be populated if the flag is of
        /// type String.
        public var stringValue: String? {
          get {
            return resultMap["stringValue"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "stringValue")
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
            name
            lastModifiedTs
            userACL {
              __typename
              acl
            }
            acl {
              __typename
              userID
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
        }
      }
    }
    """

  public let operationName: String = "ListSpaces"

  public let operationIdentifier: String? = "395bc6b167d715cb0e9194316e44cb9900c9cf8887b55ac0df273f58f189aa5e"

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
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("lastModifiedTs", type: .scalar(String.self)),
              GraphQLField("userACL", type: .object(UserAcl.selections)),
              GraphQLField("acl", type: .list(.nonNull(.object(Acl.selections)))),
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

          public init(name: String? = nil, lastModifiedTs: String? = nil, userAcl: UserAcl? = nil, acl: [Acl]? = nil, hasPublicAcl: Bool? = nil, thumbnail: String? = nil, thumbnailSize: ThumbnailSize? = nil, resultCount: Int? = nil, isDefaultSpace: Bool? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "lastModifiedTs": lastModifiedTs, "userACL": userAcl.flatMap { (value: UserAcl) -> ResultMap in value.resultMap }, "acl": acl.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, "hasPublicACL": hasPublicAcl, "thumbnail": thumbnail, "thumbnailSize": thumbnailSize.flatMap { (value: ThumbnailSize) -> ResultMap in value.resultMap }, "resultCount": resultCount, "isDefaultSpace": isDefaultSpace])
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

          public var lastModifiedTs: String? {
            get {
              return resultMap["lastModifiedTs"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "lastModifiedTs")
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

          public var acl: [Acl]? {
            get {
              return (resultMap["acl"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Acl] in value.map { (value: ResultMap) -> Acl in Acl(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, forKey: "acl")
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

          public struct Acl: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceACL"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("userID", type: .nonNull(.scalar(String.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(userId: String) {
              self.init(unsafeResultMap: ["__typename": "SpaceACL", "userID": userId])
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

public final class GetSpacesDataQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetSpacesData($ids: [String!]) {
      getSpace(input: {ids: $ids}) {
        __typename
        space {
          __typename
          pageMetadata {
            __typename
            pageID
          }
          space {
            __typename
            entities {
              __typename
              spaceEntity {
                __typename
                url
                thumbnail
              }
            }
          }
        }
      }
    }
    """

  public let operationName: String = "GetSpacesData"

  public let operationIdentifier: String? = "4ea494be399584a561f823705dd1bf398b1d0fcb3454f51ee321df2bb2de4cc8"

  public var ids: [String]?

  public init(ids: [String]?) {
    self.ids = ids
  }

  public var variables: GraphQLMap? {
    return ["ids": ids]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getSpace", arguments: ["input": ["ids": GraphQLVariable("ids")]], type: .object(GetSpace.selections)),
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
                GraphQLField("spaceEntity", type: .object(SpaceEntity.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(spaceEntity: SpaceEntity? = nil) {
              self.init(unsafeResultMap: ["__typename": "SpaceEntity", "spaceEntity": spaceEntity.flatMap { (value: SpaceEntity) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
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

            public struct SpaceEntity: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["SpaceEntityData"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("url", type: .scalar(String.self)),
                  GraphQLField("thumbnail", type: .scalar(String.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(url: String? = nil, thumbnail: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "SpaceEntityData", "url": url, "thumbnail": thumbnail])
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

public final class DeleteSpaceResultByUrlMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteSpaceResultByURL($input: DeleteSpaceResultByURLInput!) {
      deleteSpaceResultByURL(input: $input)
    }
    """

  public let operationName: String = "DeleteSpaceResultByURL"

  public let operationIdentifier: String? = "34c776b14ec3ba076ce8dbbb3bb1eaf87b51a101d777cf22b6b1f2437a897732"

  public var input: DeleteSpaceResultByURLInput

  public init(input: DeleteSpaceResultByURLInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSpaceResultByURL", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSpaceResultByUrl: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSpaceResultByURL": deleteSpaceResultByUrl])
    }

    /// API to delete entity from a space by URL.
    public var deleteSpaceResultByUrl: Bool {
      get {
        return resultMap["deleteSpaceResultByURL"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteSpaceResultByURL")
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
          type
          suggestedQuery
          boldSpan {
            __typename
            startInclusive
            endExclusive
          }
          source
          annotation {
            __typename
            annotationType
            description
            imageURL
          }
        }
        urlSuggestion {
          __typename
          icon {
            __typename
            labels
          }
          suggestedURL
          title
          author
          timestamp
          subtitle
          sourceQueryIndex
          boldSpan {
            __typename
            startInclusive
            endExclusive
          }
        }
        lenseSuggestion {
          __typename
          shortcut
          description
        }
        bangSuggestion {
          __typename
          shortcut
          description
          domain
        }
        activeLensBangInfo {
          __typename
          domain
          shortcut
          description
          type
        }
      }
    }
    """

  public let operationName: String = "Suggestions"

  public let operationIdentifier: String? = "54419649575fe082c546a9e7ff787ad849b6d02b69927adba0751d162f25499a"

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
          GraphQLField("lenseSuggestion", type: .list(.nonNull(.object(LenseSuggestion.selections)))),
          GraphQLField("bangSuggestion", type: .list(.nonNull(.object(BangSuggestion.selections)))),
          GraphQLField("activeLensBangInfo", type: .object(ActiveLensBangInfo.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(querySuggestion: [QuerySuggestion], urlSuggestion: [UrlSuggestion], lenseSuggestion: [LenseSuggestion]? = nil, bangSuggestion: [BangSuggestion]? = nil, activeLensBangInfo: ActiveLensBangInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "Suggest", "querySuggestion": querySuggestion.map { (value: QuerySuggestion) -> ResultMap in value.resultMap }, "urlSuggestion": urlSuggestion.map { (value: UrlSuggestion) -> ResultMap in value.resultMap }, "lenseSuggestion": lenseSuggestion.flatMap { (value: [LenseSuggestion]) -> [ResultMap] in value.map { (value: LenseSuggestion) -> ResultMap in value.resultMap } }, "bangSuggestion": bangSuggestion.flatMap { (value: [BangSuggestion]) -> [ResultMap] in value.map { (value: BangSuggestion) -> ResultMap in value.resultMap } }, "activeLensBangInfo": activeLensBangInfo.flatMap { (value: ActiveLensBangInfo) -> ResultMap in value.resultMap }])
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

      /// List of suggested lenses
      public var lenseSuggestion: [LenseSuggestion]? {
        get {
          return (resultMap["lenseSuggestion"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [LenseSuggestion] in value.map { (value: ResultMap) -> LenseSuggestion in LenseSuggestion(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [LenseSuggestion]) -> [ResultMap] in value.map { (value: LenseSuggestion) -> ResultMap in value.resultMap } }, forKey: "lenseSuggestion")
        }
      }

      /// List of suggested bangs
      public var bangSuggestion: [BangSuggestion]? {
        get {
          return (resultMap["bangSuggestion"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [BangSuggestion] in value.map { (value: ResultMap) -> BangSuggestion in BangSuggestion(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [BangSuggestion]) -> [ResultMap] in value.map { (value: BangSuggestion) -> ResultMap in value.resultMap } }, forKey: "bangSuggestion")
        }
      }

      /// Info on the currently active lens or bang
      public var activeLensBangInfo: ActiveLensBangInfo? {
        get {
          return (resultMap["activeLensBangInfo"] as? ResultMap).flatMap { ActiveLensBangInfo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "activeLensBangInfo")
        }
      }

      public struct QuerySuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["QuerySuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(QuerySuggestionType.self))),
            GraphQLField("suggestedQuery", type: .nonNull(.scalar(String.self))),
            GraphQLField("boldSpan", type: .nonNull(.list(.nonNull(.object(BoldSpan.selections))))),
            GraphQLField("source", type: .nonNull(.scalar(QuerySuggestionSource.self))),
            GraphQLField("annotation", type: .object(Annotation.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(type: QuerySuggestionType, suggestedQuery: String, boldSpan: [BoldSpan], source: QuerySuggestionSource, annotation: Annotation? = nil) {
          self.init(unsafeResultMap: ["__typename": "QuerySuggestion", "type": type, "suggestedQuery": suggestedQuery, "boldSpan": boldSpan.map { (value: BoldSpan) -> ResultMap in value.resultMap }, "source": source, "annotation": annotation.flatMap { (value: Annotation) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
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

        public var suggestedQuery: String {
          get {
            return resultMap["suggestedQuery"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "suggestedQuery")
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

        public var annotation: Annotation? {
          get {
            return (resultMap["annotation"] as? ResultMap).flatMap { Annotation(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "annotation")
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

        public struct Annotation: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Annotation"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("annotationType", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("imageURL", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(annotationType: String? = nil, description: String? = nil, imageUrl: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Annotation", "annotationType": annotationType, "description": description, "imageURL": imageUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var annotationType: String? {
            get {
              return resultMap["annotationType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "annotationType")
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

          public var imageUrl: String? {
            get {
              return resultMap["imageURL"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "imageURL")
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
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("author", type: .scalar(String.self)),
            GraphQLField("timestamp", type: .scalar(String.self)),
            GraphQLField("subtitle", type: .scalar(String.self)),
            GraphQLField("sourceQueryIndex", type: .scalar(Int.self)),
            GraphQLField("boldSpan", type: .nonNull(.list(.nonNull(.object(BoldSpan.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(icon: Icon, suggestedUrl: String, title: String? = nil, author: String? = nil, timestamp: String? = nil, subtitle: String? = nil, sourceQueryIndex: Int? = nil, boldSpan: [BoldSpan]) {
          self.init(unsafeResultMap: ["__typename": "URLSuggestion", "icon": icon.resultMap, "suggestedURL": suggestedUrl, "title": title, "author": author, "timestamp": timestamp, "subtitle": subtitle, "sourceQueryIndex": sourceQueryIndex, "boldSpan": boldSpan.map { (value: BoldSpan) -> ResultMap in value.resultMap }])
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

        public var title: String? {
          get {
            return resultMap["title"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "title")
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

        public var subtitle: String? {
          get {
            return resultMap["subtitle"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "subtitle")
          }
        }

        public var sourceQueryIndex: Int? {
          get {
            return resultMap["sourceQueryIndex"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "sourceQueryIndex")
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

      public struct LenseSuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["LenseSuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("shortcut", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(shortcut: String? = nil, description: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "LenseSuggestion", "shortcut": shortcut, "description": description])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var shortcut: String? {
          get {
            return resultMap["shortcut"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "shortcut")
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
      }

      public struct BangSuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["BangSuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("shortcut", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("domain", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(shortcut: String? = nil, description: String? = nil, domain: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "BangSuggestion", "shortcut": shortcut, "description": description, "domain": domain])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var shortcut: String? {
          get {
            return resultMap["shortcut"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "shortcut")
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

        public var domain: String? {
          get {
            return resultMap["domain"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "domain")
          }
        }
      }

      public struct ActiveLensBangInfo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ActiveLensBangInfo"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("domain", type: .scalar(String.self)),
            GraphQLField("shortcut", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("type", type: .scalar(ActiveLensBangType.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(domain: String? = nil, shortcut: String? = nil, description: String? = nil, type: ActiveLensBangType? = nil) {
          self.init(unsafeResultMap: ["__typename": "ActiveLensBangInfo", "domain": domain, "shortcut": shortcut, "description": description, "type": type])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var domain: String? {
          get {
            return resultMap["domain"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "domain")
          }
        }

        public var shortcut: String? {
          get {
            return resultMap["shortcut"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "shortcut")
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

        public var type: ActiveLensBangType? {
          get {
            return resultMap["type"] as? ActiveLensBangType
          }
          set {
            resultMap.updateValue(newValue, forKey: "type")
          }
        }
      }
    }
  }
}

public final class SearchResultsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query SearchResults($query: String!) {
      search(q: $query) {
        __typename
        resultGroup {
          __typename
          result {
            __typename
            actionURL
          }
        }
      }
    }
    """

  public let operationName: String = "SearchResults"

  public let operationIdentifier: String? = "3f56834e1bcd1e8fe6b3fba04935f3417710ba801be600b88f2dab3452e43679"

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
        GraphQLField("search", arguments: ["q": GraphQLVariable("query")], type: .object(Search.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(search: Search? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "search": search.flatMap { (value: Search) -> ResultMap in value.resultMap }])
    }

    /// The main search query. Note that latitude and longitude are deprecated parameters as of 2020/03/05 but kept for iOS app compatibility.
    public var search: Search? {
      get {
        return (resultMap["search"] as? ResultMap).flatMap { Search(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "search")
      }
    }

    public struct Search: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Search"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("resultGroup", type: .list(.object(ResultGroup.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(resultGroup: [ResultGroup?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Search", "resultGroup": resultGroup.flatMap { (value: [ResultGroup?]) -> [ResultMap?] in value.map { (value: ResultGroup?) -> ResultMap? in value.flatMap { (value: ResultGroup) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Results are grouped into 0 or more result groups according to criteria
      /// decided by the backend.
      public var resultGroup: [ResultGroup?]? {
        get {
          return (resultMap["resultGroup"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ResultGroup?] in value.map { (value: ResultMap?) -> ResultGroup? in value.flatMap { (value: ResultMap) -> ResultGroup in ResultGroup(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [ResultGroup?]) -> [ResultMap?] in value.map { (value: ResultGroup?) -> ResultMap? in value.flatMap { (value: ResultGroup) -> ResultMap in value.resultMap } } }, forKey: "resultGroup")
        }
      }

      public struct ResultGroup: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ResultGroup"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("result", type: .list(.object(Result.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(result: [Result?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "ResultGroup", "result": result.flatMap { (value: [Result?]) -> [ResultMap?] in value.map { (value: Result?) -> ResultMap? in value.flatMap { (value: Result) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// An ordered list of all the results.
        public var result: [Result?]? {
          get {
            return (resultMap["result"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Result?] in value.map { (value: ResultMap?) -> Result? in value.flatMap { (value: ResultMap) -> Result in Result(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Result?]) -> [ResultMap?] in value.map { (value: Result?) -> ResultMap? in value.flatMap { (value: Result) -> ResultMap in value.resultMap } } }, forKey: "result")
          }
        }

        public struct Result: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Result"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("actionURL", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(actionUrl: String) {
            self.init(unsafeResultMap: ["__typename": "Result", "actionURL": actionUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The primary url to navigate to when the user clicks on a result.
          public var actionUrl: String {
            get {
              return resultMap["actionURL"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "actionURL")
            }
          }
        }
      }
    }
  }
}
