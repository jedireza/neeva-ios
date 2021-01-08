import Apollo
import SwiftUI
import Combine

public typealias Updater<T> = (((inout T) -> ())?) -> ()

/**
 * The `perform` methods are intended to be used only by subclasses, to help implement their custom query methods.
 */
public class QueryController<Query, Data>: ObservableObject where Query: GraphQLQuery {
    @Published public private(set) var running = false
    @Published public private(set) var error: Error?
    @Published public private(set) var data: Data?

    public init() {
        self.reload()
    }

    @discardableResult public func perform(query: Query) -> Apollo.Cancellable {
        running = true
        error = nil
        return Self.perform(query: query) {
            self.running = false
            self.data = nil
            switch $0 {
            case .failure(let error): self.error = error
            case .success(let data): self.data = data
            }
        }
    }

    public func reload() {
        fatalError("\(self).\(#function) not implemented")
    }
    /// optimisticResult is an optional expected result of the query
    public func reload(optimisticResult: Data?) {
        if let optimisticResult = optimisticResult {
            data = optimisticResult
        }
        self.reload()
    }

    public class func processData(_ data: Query.Data) -> Data {
        fatalError("\(self).\(#function) not implemented")
    }

    public class func processData(_ data: Query.Data, for query: Query) -> Data {
        processData(data)
    }

    @discardableResult public class func perform(
        query: Query,
        completion: @escaping (Result<Data, Error>) -> ()
    ) -> Apollo.Cancellable {
        query.fetch { result in
            switch result {
            case .success(let data):
                completion(.success(processData(data, for: query)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension QueryController where Data == Query.Data {
    public static func processData(_ data: Query.Data) -> Data { data }
}
