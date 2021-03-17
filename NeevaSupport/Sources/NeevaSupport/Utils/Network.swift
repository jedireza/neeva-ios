import SwiftUI
import Apollo

/// This singleton class manages access to the Neeva GraphQL API
public class GraphQLAPI {
    /// Access the API through this instance
    public static let shared = GraphQLAPI()

    private init() {}

    /// The `ApolloClient` des the actual work of peforming GraphQL requests.
    public private(set) lazy var apollo: ApolloClient = {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let provider = LegacyInterceptorProvider(store: store)
        let transport = NeevaNetworkTransport(
            interceptorProvider: provider,
            endpointURL: NeevaConstants.appURL / "graphql"
        )

        return ApolloClient(networkTransport: transport, store: store)
    }()

    /// A `GraphQLAPI.Error` is returned when the HTTP request was successful
    /// but there are one or more error messages in the `errors` array.
    public class Error: Swift.Error, CustomStringConvertible {
        /// the underlying errors
        public let errors: [GraphQLError]
        init(_ errors: [GraphQLError]) {
            self.errors = errors
        }

        public var description: String { localizedDescription }
        public var localizedDescription: String {
            "GraphQLAPI.Error(\(errors.map(\.message)))"
        }
    }

    /// Make the raw result of a GraphQL API call more useful
    static func unwrap<Data>(result: Result<GraphQLResult<Data>, Swift.Error>) -> Result<Data, Swift.Error> {
        switch result {
        case .success(let result):
            if let errors = result.errors, !errors.isEmpty {
                return .failure(Error(errors))
            } else if let data = result.data {
                return .success(data)
            } else {
                return .failure(GraphQLError([ "message": "No data provided" ]))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

/// Provide relevant headers and cookies, and update the URL based on the latest preferences
class NeevaNetworkTransport: RequestChainNetworkTransport {
    override func constructRequest<Operation>(
        for operation: Operation, cachePolicy: CachePolicy,
        contextIdentifier: UUID? = nil
    ) -> HTTPRequest<Operation> where Operation : GraphQLOperation {
        let req = super.constructRequest(for: operation, cachePolicy: cachePolicy, contextIdentifier: contextIdentifier)
        req.graphQLEndpoint = NeevaConstants.appURL / "graphql" / operation.operationName

        req.addHeader(name: NeevaConstants.Header.deviceType.name, value: NeevaConstants.Header.deviceType.value)
        req.addHeader(name: "X-Neeva-Client-ID", value: "co.neeva.app.ios.browser")
        req.addHeader(name: "X-Neeva-Client-Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)

        if let cookie = try? NeevaConstants.keychain.getString(NeevaConstants.loginKeychainKey) {
            assignCookie(cookie)
        } else if
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
            let devTokenPath = Bundle.module.path(forResource: "dev-token", ofType: "txt") {
            // if in an Xcode preview, use the cookie from `dev-token.txt`. See `README.md` for more details.
            // only works on the second try for some reason
            _ = try? String(contentsOf: URL(fileURLWithPath: devTokenPath))
            if let cookie = try? String(contentsOf: URL(fileURLWithPath: devTokenPath)) {
                assignCookie(cookie.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        return req
    }

    private func assignCookie(_ value: String) {
        // only used for URLRequest, not the webview
        if let cookie = HTTPCookie(properties: [
            .name: "httpd~login",
            .value: value,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
            .secure: true,
            .sameSitePolicy: HTTPCookieStringPolicy.sameSiteLax,
            // ! potentially undocumented API
            .init("HttpOnly"): true
        ]) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }
}

extension GraphQLQuery {
    /// Call this method on a GraphQL query to perform an authenticated fetch
    @discardableResult
    public func fetch(
        on queue: DispatchQueue = DispatchQueue.main,
        resultHandler: ((Result<Data, Swift.Error>) -> ())? = nil
    ) -> Cancellable {
        GraphQLAPI.shared.apollo.fetch(
            query: self,
            cachePolicy: .fetchIgnoringCacheCompletely,
            queue: queue
        ) { result in
            resultHandler?(GraphQLAPI.unwrap(result: result))
        }
    }
}

extension GraphQLMutation {
    /// Call this method on a GraphQL mutation to execute it with authentication.
    @discardableResult
    public func perform(
        on queue: DispatchQueue = .main,
        resultHandler: ((Result<Data, Swift.Error>) -> ())? = nil
    ) -> Cancellable {
        GraphQLAPI.shared.apollo.perform(
            mutation: self,
            publishResultToStore: false,
            queue: queue
        ) { result in
            resultHandler?(GraphQLAPI.unwrap(result: result))
        }
    }
}
