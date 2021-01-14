import Apollo
import SwiftUI
import Combine

public typealias Updater<T> = (((inout T) -> ())?) -> ()

/**
 * The `perform` methods are intended to be used only by subclasses, to help implement their custom query methods.
 */
public class QueryController<Query, Data>: ObservableObject where Query: GraphQLQuery {
    public enum State {
        case running
        case success(Data)
        case failure(Error)

        public var isRunning: Bool {
            switch self {
            case .running: return true
            default: return false
            }
        }

        public var data: Data? {
            switch self {
            case .success(let data): return data
            default: return nil
            }
        }
    }
    @Published public private(set) var state = State.running

    var animation: Animation?

    public init(animation: Animation? = nil) {
        self.animation = animation
        self.reload()
    }

    func withOptionalAnimation<Result>(_ body: () throws -> Result) rethrows -> Result {
        if let animation = animation {
            return try withAnimation(animation, body)
        } else {
            return try body()
        }
    }

    @discardableResult public func perform(query: Query) -> Apollo.Cancellable {
        var stillRunning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            if stillRunning, case .failure = self.state {
                self.state = .running
            }
        }
        return Self.perform(query: query) { result in
            stillRunning = false
            self.withOptionalAnimation {
                switch result {
                case .failure(let error):
                    self.state = .failure(error)
                case .success(let data):
                    self.state = .success(data)
                }
            }
        }
    }

    public func reload() {
        fatalError("\(self).\(#function) not implemented")
    }
    /// optimisticResult is an optional expected result of the query
    public func reload(optimisticResult: Data?) {
        if let optimisticResult = optimisticResult {
            withOptionalAnimation {
                state = .success(optimisticResult)
            }
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
