//
//  ACLView.swift
//  
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI

/// A selector for available access levels.
struct ACLPicker: View {
    @Binding var acl: SpaceACLLevel
    var body: some View {
        Picker(selection: $acl, label: HStack {
            Text("Can \(acl.rawValue.lowercased())")
            Image(systemName: "chevron.down")
                .accessibilityHidden(true)
        }, content: {
            Text("Can edit").tag(SpaceACLLevel.edit)
            Text("Can comment").tag(SpaceACLLevel.comment)
            Text("Can view").tag(SpaceACLLevel.view)
        })
        .pickerStyle(MenuPickerStyle())
        .accessibilityHint("Double-tap to change access level")
    }
}

/// Displays user information along with informative text, if applicable
struct ACLView: View {
    let profile: UserProfile
    let canEdit: Bool
    @StateObject var controller: UserACLController

    /// - Parameters:
    ///   - acl: An `Acl` object, which contains the user’s info and their current access level
    ///   - canEdit: Whether the logged-in user can edit this ACL. If `false`, only the owner’s access level will be visible.
    ///   - spaceId: the space that this ACL is attached to
    init(acl: SpaceController.Space.Acl, canEdit: Bool, spaceId: String) {
        self.profile = acl.profile
        self.canEdit = canEdit
        self._controller = .init(wrappedValue: UserACLController(spaceId: spaceId, userId: acl.userId, level: acl.acl))
    }

    var body: some View {
        HStack {
            UserDetailView(profile)
            Spacer()
            if controller.level == .owner {
                Text("Owner")
            } else if canEdit {
                ACLPicker(acl: $controller.level)
            } // otherwise, display nothing
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
        .accessibilityActivationPoint(UnitPoint(x: 0.9, y: 0.5))
    }
}

struct ACLView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section {
                ForEach(testSpace.acl!) { acl in
                    ACLView(acl: acl, canEdit: true, spaceId: "")
                }
            }
            Section {
                ForEach(testSpace.acl!) { acl in
                    ACLView(acl: acl, canEdit: false, spaceId: "")
                }
            }
        }
    }
}
