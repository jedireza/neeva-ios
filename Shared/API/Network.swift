// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine

// Neeva API access is restricted. Contact Neeva to request approval
// before extending this list.
private let approvedBundleIDs = [
    "co.neeva.app.ios.browser",
    "co.neeva.app.ios.browser-dev",
    "xyz.neeva.app.ios.browser",
    "xyz.neeva.app.ios.browser-dev",
]

/// This singleton class manages access to the Neeva GraphQL API
public class GraphQLAPI {
    /// Access the API through this instance
    public static let shared = GraphQLAPI()

    private init() {}

    public var isAnonymous = false

    /// The `ApolloClient` does the actual work of performing GraphQL requests.
    public private(set) lazy var apollo: ApolloClient = {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let provider = DefaultInterceptorProvider(store: store)

        var transport: NetworkTransport
        if approvedBundleIDs.contains(AppInfo.baseBundleIdentifier) {
            transport = NeevaNetworkTransport(
                interceptorProvider: provider,
                endpointURL: NeevaConstants.appURL / "graphql"
            )
        } else {
            fatalError(
                """
                    Bundle ID \(AppInfo.baseBundleIdentifier) cannot access the Neeva API.
                    Contact Neeva to request approval for API access.
                """)
        }

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
    static func unwrap<Data>(result: Result<GraphQLResult<Data>, Swift.Error>) -> Result<
        Data, Swift.Error
    > {
        switch result {
        case .success(let result):
            if let errors = result.errors, !errors.isEmpty {
                return .failure(Error(errors))
            } else if let data = result.data {
                return .success(data)
            } else {
                return .failure(GraphQLError(["message": "No data provided"]))
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
    ) -> HTTPRequest<Operation> where Operation: GraphQLOperation {
        let req = super.constructRequest(
            for: operation, cachePolicy: cachePolicy, contextIdentifier: contextIdentifier)
        req.graphQLEndpoint = NeevaConstants.appURL / "graphql" / operation.operationName

        req.addHeader(name: "User-Agent", value: "NeevaBrowserIOS")
        req.addHeader(
            name: NeevaConstants.Header.deviceType.name,
            value: NeevaConstants.Header.deviceType.value)
        req.addHeader(name: "X-Neeva-Client-ID", value: "co.neeva.app.ios.browser")
        req.addHeader(name: "X-Neeva-Client-Version", value: AppInfo.appVersionReportedToNeeva)

        if !GraphQLAPI.shared.isAnonymous, let cookie = NeevaUserInfo.shared.getLoginCookie() {
            assignCookie(cookie)
        } else if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
            let devTokenPath = Bundle.main.path(forResource: "dev-token", ofType: "txt")
        {
            // if in an Xcode preview, use the cookie from `dev-token.txt`. See `README.md` for more details.
            // only works on the second try for some reason
            _ = try? String(contentsOf: URL(fileURLWithPath: devTokenPath))
            if let cookie = try? String(contentsOf: URL(fileURLWithPath: devTokenPath)) {
                assignCookie(cookie.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        } else {
            // Else, let this request fail with an authentication error.
            clearCookie()
        }
        return req
    }

    private func assignCookie(_ value: String) {
        // only used for URLRequest, not the webview
        HTTPCookieStorage.shared.setCookie(NeevaConstants.loginCookie(for: value))
    }

    private func clearCookie() {
        if let cookies = HTTPCookieStorage.shared.cookies(for: NeevaConstants.appURL) {
            if let loginCookie = cookies.first(where: { $0.name == "httpd~login" }) {
                HTTPCookieStorage.shared.deleteCookie(loginCookie)
            }

            // we are not storing preview~login, but there is an older version of our app
            // that would store the preview cookie, adding this delete to make sure
            // we clean up things properly
            if let previewCookie = cookies.first(where: { $0.name == "preview~login" }) {
                HTTPCookieStorage.shared.deleteCookie(previewCookie)
            }
        }
    }
}

extension GraphQLQuery {
    /// Call this method on a GraphQL query to perform an authenticated fetch
    @discardableResult
    public func fetch(
        on queue: DispatchQueue = DispatchQueue.main,
        resultHandler: ((Result<Data, Swift.Error>) -> Void)? = nil
    ) -> Combine.Cancellable {
        GraphQLAPI.shared.apollo.fetch(
            query: self,
            cachePolicy: .fetchIgnoringCacheCompletely,
            queue: queue
        ) { result in
            resultHandler?(GraphQLAPI.unwrap(result: result))
        }.combine
    }
}

extension GraphQLMutation {
    /// Call this method on a GraphQL mutation to execute it with authentication.
    @discardableResult
    public func perform(
        on queue: DispatchQueue = .main,
        resultHandler: ((Result<Data, Swift.Error>) -> Void)? = nil
    ) -> Combine.Cancellable {
        GraphQLAPI.shared.apollo.perform(
            mutation: self,
            publishResultToStore: false,
            queue: queue
        ) { result in
            resultHandler?(GraphQLAPI.unwrap(result: result))
        }.combine
    }
}
