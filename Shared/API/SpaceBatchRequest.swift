// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

public class SpaceBatchRequest: ObservableObject {
    let spaceID: String
    let type: RequestType

    public init(for spaceID: String, to type: RequestType, entities: [String]) {
        self.spaceID = spaceID
        self.type = type

        switch type {
        case .delete:
            delete(entities: entities)
        case .reorder:
            reorder(entities: entities)
        }
    }

    private var subcription: Apollo.Cancellable? = nil

    public enum State {
        case initial
        case success
        case failure
    }

    public enum RequestType {
        case delete
        case reorder
    }

    @Published public var state: State = .initial
    @Published public var error: Error?

    private func reorder(entities: [String]) {
        assert(subcription == nil)

        self.subcription = SetSpaceDetailPageSortOrderMutation(
            input: SetSpaceDetailPageSortOrderInput(
                spaceId: spaceID,
                attribute: nil,
                sortOrderType: .custom,
                customSortOrder: CustomSortOrderInput(resultIDs: entities)
            )
        ).perform { result in
            self.subcription = nil
            switch result {
            case .failure(let error):
                self.error = error
                self.state = .failure
                break
            case .success(_):
                self.state = .success
            }
        }
    }

    private func delete(entities: [String]) {
        assert(subcription == nil)

        self.subcription = BatchDeleteSpaceResultMutation(
            input: BatchDeleteSpaceResultInput(
                spaceId: spaceID, resultIDs: entities
            )
        ).perform { result in
            self.subcription = nil
            switch result {
            case .failure(let error):
                self.error = error
                self.state = .failure
                break
            case .success(_):
                self.state = .success
            }
        }
    }
}
