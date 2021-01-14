import Apollo
import SwiftUI
import Combine

/**
 * The `execute` method is intended to be used only by subclasses, to help implement their custom mutation methods.
 */
public class MutationController<Mutation, Container>: ObservableObject where Mutation: GraphQLMutation {
    @Published public private(set) var cancellable: Apollo.Cancellable?

    var isRunning: Bool { cancellable != nil }

    var animation: Animation?
    var onUpdate: Updater<Container>
    var onSuccess: () -> ()

    public init(animation: Animation? = nil, onUpdate: @escaping Updater<Container>, onSuccess: @escaping () -> () = {}) {
        self.animation = animation
        self.onUpdate = onUpdate
        self.onSuccess = onSuccess
    }

    func withOptionalAnimation<Result>(_ body: () throws -> Result) rethrows -> Result {
        if let animation = animation {
            return try withAnimation(animation, body)
        } else {
            return try body()
        }
    }

    public func execute(mutation: Mutation) {
        cancellable = mutation.perform { result in
            self.withOptionalAnimation {
                self.cancellable = nil
                switch result {
                case .failure(_):
                    self.onUpdate(nil)
                case .success(let data):
                    self.onSuccess()
                    self.onUpdate {
                        self.update(&$0, from: data, after: mutation)
                    }
                }
            }
        }
    }

    public func update(_ optimisticResult: inout Container, from result: Mutation.Data, after mutation: Mutation) {
        fatalError("\(self).\(#function) not implemented")
    }
}
