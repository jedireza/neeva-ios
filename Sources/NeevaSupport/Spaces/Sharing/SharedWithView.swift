//
//  SharedWithView.swift
//  
//
//  Created by Jed Fox on 1/6/21.
//

import SwiftUI

typealias Acl = SpaceController.Space.Acl
func separate(_ users: [Acl]) -> (owners: [Acl], others: [Acl]) {
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

struct SharedWithView: View {
    let users: [SpaceController.Space.Acl]
    let canEdit: Bool
    let spaceId: String
    let onUpdate: Updater<SpaceController.Space>

    var body: some View {
        Section {
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

    func remove(users: [Acl]) {
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
