import Apollo
import Combine

/**
 * The `perform` methods are intended to be used only by subclasses, to help implement their custom query methods.
 */
public class QueryController<Query, Data>: ObservableObject where Query: GraphQLQuery {
    @Published public var running = false
    @Published public var error: Error?
    @Published public var data: Data?

    public init() {}

    @discardableResult public func perform(query: Query) -> Apollo.Cancellable {
        running = true
        error = nil
        data = nil
        return Self.perform(query: query) {
            self.running = false
            switch $0 {
            case .failure(let error): self.error = error
            case .success(let data): self.data = data
            }
        }
    }

    public class func processData(_ data: Query.Data) -> Data {
        fatalError("\(self).\(#function) not implemented")
    }

    @discardableResult public class func perform(
        query: Query,
        completion: @escaping (Result<Data, Error>) -> ()
    ) -> Apollo.Cancellable {
        GraphQLAPI.fetch(query) { result in
            switch result {
            case .success(let data):
                completion(.success(processData(data)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension QueryController where Data == Query.Data {
    public static func processData(_ data: Query.Data) -> Data { data }
}
