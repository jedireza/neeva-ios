//
//  SharedWithView.swift
//  
//
//  Created by Jed Fox on 1/6/21.
//

import SwiftUI

typealias Acl = SpaceController.Space.Acl

// for placing the owner(s) first in the list, and preventing them from being removed
fileprivate func separate(_ users: [Acl]) -> (owners: [Acl], others: [Acl]) {
    var owners = [Acl]()
    var others = [Acl]()
    for user in users {
        if user.acl == .owner {
            owners.append(user)
        } else {
            others.append(user)
        }
    }
    return (owners, others)
}

/// Displays the list of users the space is shared with
struct SharedWithView: View {
    /// The list of users the space is shared with
    let users: [SpaceController.Space.Acl]
    /// Can the currently logged in user edit the sharing details of this space?
    let canEdit: Bool
    /// The ID of this space
    let spaceId: String
    /// See `SpaceLoaderView`
    let onUpdate: Updater<SpaceController.Space>

    var body: some View {
        DecorativeSection {
            let (owners, others) = separate(users)
            ForEach(owners) { acl in
                ACLView(acl: acl, canEdit: canEdit, spaceId: spaceId)
            }
            ForEach(others) { acl in
                ACLView(acl: acl, canEdit: canEdit, spaceId: spaceId)
            }.onDelete { indexSet in
                remove(users: indexSet.map { others[$0] })
            }
        }
    }

    private func remove(users: [Acl]) {
        guard canEdit else { return }

        var totalReturned = 0, totalSuccess = 0
        for user in users {
            DeleteUserSpaceAclMutation(space: spaceId, user: user.id).perform { result in
                totalReturned += 1
                if case .success(let data) = result, data.deleteUserSpaceAcl {
                    totalSuccess += 1
                }
                if totalReturned == users.count {
                    if totalSuccess == totalReturned {
                        onUpdate { newSpace in
                            for user in users {
                                newSpace.acl?.removeAll { $0.id == user.id }
                            }
                        }
                    } else {
                        onUpdate(nil)
                    }
                }
            }
        }
    }
}
