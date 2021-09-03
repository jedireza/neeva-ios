// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

public class SpaceRequest<Mutation: GraphQLMutation>: ObservableObject {
    private var subcription: Apollo.Cancellable? = nil

    public enum State {
        case initial
        case success
        case failure
    }

    @Published public var state: State = .initial
    @Published public var error: Error?

    init(mutation: Mutation) {
        assert(subcription == nil)

        self.subcription = mutation.perform { result in
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

public class AddPublicACLRequest: SpaceRequest<AddSpacePublicAclMutation> {
    public init(spaceID: String) {
        super.init(mutation: AddSpacePublicAclMutation(input: AddSpacePublicACLInput(id: spaceID)))
    }
}

public class DeletePublicACLRequest: SpaceRequest<DeleteSpacePublicAclMutation> {
    public init(spaceID: String) {
        super.init(
            mutation: DeleteSpacePublicAclMutation(input: DeleteSpacePublicACLInput(id: spaceID)))
    }
}

public class AddSoloACLsRequest: SpaceRequest<AddSpaceSoloAcLsMutation> {
    public init(spaceID: String, emails: [String], acl: SpaceACLLevel) {
        super.init(
            mutation: AddSpaceSoloAcLsMutation(
                input: AddSpaceSoloACLsInput(
                    id: spaceID, shareWith: emails.map { SpaceEmailACL(email: $0, acl: acl) })))
    }
}

public class DeleteSpaceItemsRequest: SpaceRequest<BatchDeleteSpaceResultMutation> {
    public init(spaceID: String, ids: [String]) {
        super.init(
            mutation: BatchDeleteSpaceResultMutation(
                input: BatchDeleteSpaceResultInput(
                    spaceId: spaceID, resultIDs: ids)))
    }
}

public class ReorderSpaceRequest: SpaceRequest<SetSpaceDetailPageSortOrderMutation> {
    public init(spaceID: String, ids: [String]) {
        super.init(
            mutation: SetSpaceDetailPageSortOrderMutation(
                input: SetSpaceDetailPageSortOrderInput(
                    spaceId: spaceID, attribute: nil, sortOrderType: .custom,
                    customSortOrder: CustomSortOrderInput(resultIDs: ids))))
    }
}
