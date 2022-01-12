// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine

public class SpaceRequest<Mutation: GraphQLMutation>: ObservableObject {
    private var subcription: Combine.Cancellable? = nil

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

public class CreateSpaceRequest: SpaceRequest<CreateSpaceMutation> {
    public init(name: String) {
        super.init(mutation: CreateSpaceMutation(name: name))
    }
}

public class DeleteSpaceRequest: SpaceRequest<DeleteSpaceMutation> {
    public init(spaceID: String) {
        super.init(mutation: DeleteSpaceMutation(input: DeleteSpaceInput(id: spaceID)))
    }
}

public class DeleteGeneratorRequest: SpaceRequest<DeleteSpaceGeneratorMutation> {
    public init(spaceID: String, generatorID: String) {
        super.init(
            mutation: DeleteSpaceGeneratorMutation(
                input: DeleteSpaceGeneratorInput(spaceId: spaceID, generatorId: generatorID)))
    }
}

public class UnfollowSpaceRequest: SpaceRequest<LeaveSpaceMutation> {
    public init(spaceID: String) {
        super.init(mutation: LeaveSpaceMutation(input: LeaveSpaceInput(id: spaceID)))
    }
}

public class UpdateSpaceRequest: SpaceRequest<UpdateSpaceMutation> {
    public init(
        spaceID: String, title: String,
        description: String? = nil, thumbnail: String? = nil
    ) {
        super.init(
            mutation: UpdateSpaceMutation(
                input: UpdateSpaceInput(
                    id: spaceID, name: title,
                    description: description, thumbnail: thumbnail)))
    }
}

public class ClaimGeneratedItem: SpaceRequest<ClaimGeneratedItemMutation> {
    public init(spaceID: String, entityID: String) {
        super.init(
            mutation: ClaimGeneratedItemMutation(
                input: ClaimGeneratedItemInput(spaceId: spaceID, resultId: entityID)))
    }
}

public class AddSpaceCommentRequest: SpaceRequest<AddSpaceCommentMutation> {
    public init(spaceID: String, comment: String) {
        super.init(
            mutation: AddSpaceCommentMutation(
                input: AddSpaceCommentInput(spaceId: spaceID, comment: comment)))
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
    public init(spaceID: String, emails: [String], acl: SpaceACLLevel, note: String) {
        super.init(
            mutation: AddSpaceSoloAcLsMutation(
                input: AddSpaceSoloACLsInput(
                    id: spaceID, shareWith: emails.map { SpaceEmailACL(email: $0, acl: acl) },
                    note: note)))
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

public class UpdateSpaceEntityRequest: SpaceRequest<UpdateSpaceEntityDisplayDataMutation> {
    public init(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?
    ) {
        super.init(
            mutation: UpdateSpaceEntityDisplayDataMutation(
                input: UpdateSpaceEntityDisplayDataInput(
                    spaceId: spaceID, resultId: entityID, title: title, snippet: snippet,
                    thumbnail: thumbnail)))
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

public class AddToSpaceWithURLRequest: SpaceRequest<AddToSpaceMutation> {
    public init(spaceID: String, url: String, title: String, description: String?) {
        super.init(
            mutation: AddToSpaceMutation(
                input: AddSpaceResultByURLInput(
                    spaceId: spaceID, url: url, title: title,
                    data: description, mediaType: "text/plain")))
    }
}

public class UpdateProfileRequest: SpaceRequest<UpdateUserProfileMutation> {
    public init(firstName: String, lastName: String) {
        super.init(
            mutation: UpdateUserProfileMutation(
                input: UpdateUserProfileInput(firstName: firstName, lastName: lastName)))
    }
}
