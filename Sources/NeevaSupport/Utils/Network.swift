import SwiftUI
import Apollo
import SwiftKeychainWrapper

public typealias JSONObject = Apollo.JSONObject
public typealias JSONValue = Apollo.JSONValue

public class GraphQLAPI {
    public static let shared = GraphQLAPI()

    private(set) lazy var apollo: ApolloClient = {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let provider = LegacyInterceptorProvider(store: store)
        let transport = NeevaNetworkTransport(
            interceptorProvider: provider,
            endpointURL: URL(string: "https://alpha.neeva.co/graphql")!
        )
        return ApolloClient(networkTransport: transport, store: store)
    }()

    public class Error: Swift.Error {
        public let errors: [GraphQLError]
        init(_ errors: [GraphQLError]) {
            self.errors = errors
        }
    }

    static func unwrap<Data>(result: Result<GraphQLResult<Data>, Swift.Error>) -> Result<Data, Swift.Error> {
        switch result {
        case .success(let result):
            if let errors = result.errors {
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

    @discardableResult public static func fetch<Query: GraphQLQuery>(
        _ query: Query,
        queue: DispatchQueue = DispatchQueue.main,
        resultHandler: ((Result<Query.Data, Swift.Error>) -> ())? = nil
    ) -> Cancellable {
        shared.apollo.fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely,
            queue: queue
        ) { result in
            resultHandler?(unwrap(result: result))
        }
    }

    @discardableResult public static func perform<Mutation: GraphQLMutation>(
        _ mutation: Mutation,
        queue: DispatchQueue = .main,
        resultHandler: ((Result<Mutation.Data, Swift.Error>) -> ())? = nil
    ) -> Cancellable {
        shared.apollo.perform(
            mutation: mutation,
            publishResultToStore: false,
            queue: queue
        ) { result in
            resultHandler?(unwrap(result: result))
        }
    }
}

class NeevaNetworkTransport: RequestChainNetworkTransport {
    override func constructRequest<Operation>(
        for operation: Operation, cachePolicy: CachePolicy,
        contextIdentifier: UUID? = nil
    ) -> HTTPRequest<Operation> where Operation : GraphQLOperation {
        let req = super.constructRequest(for: operation, cachePolicy: cachePolicy, contextIdentifier: contextIdentifier)
        if let cookie = KeychainWrapper.standard.string(forKey: NeevaConstants.loginKeychainKey) {
            req.addHeader(name: "Cookie", value: "httpd~login=\(cookie)")
        } else if
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
            let devTokenPath = Bundle.module.path(forResource: "dev-token", ofType: "txt") {
            // only works on the second try for some reason
            _ = try? String(contentsOf: URL(fileURLWithPath: devTokenPath))
            if let cookie = try? String(contentsOf: URL(fileURLWithPath: devTokenPath)) {
                req.addHeader(name: "Cookie", value: "httpd~login=\(cookie.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
        }
        return req
    }
}
