import Foundation
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

    @discardableResult public static func fetch<Query: GraphQLQuery>(
        query: Query,
        queue: DispatchQueue = DispatchQueue.main,
        resultHandler: GraphQLResultHandler<Query.Data>? = nil
    ) -> Cancellable {
        shared.apollo.fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely,
            queue: queue,
            resultHandler: resultHandler
        )
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
        }
        return req
    }
}
