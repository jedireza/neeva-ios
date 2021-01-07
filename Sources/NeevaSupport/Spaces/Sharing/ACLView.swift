//
//  ACLView.swift
//  
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI

struct ACLPicker: View {
    @Binding var acl: SpaceACLLevel
    var body: some View {
        Picker(selection: $acl, label: HStack {
            Text("Can \(acl.rawValue.lowercased())")
            Image(systemName: "chevron.down")
        }, content: {
            Text("Can edit").tag(SpaceACLLevel.edit)
            Text("Can comment").tag(SpaceACLLevel.comment)
            Text("Can view").tag(SpaceACLLevel.view)
        }).pickerStyle(MenuPickerStyle())
    }
}

struct ACLView: View {
    let acl: SpaceController.Space.Acl
    let canEdit: Bool
    @StateObject var controller: UserACLController
    init(acl: SpaceController.Space.Acl, canEdit: Bool, spaceId: String) {
        self.acl = acl
        self.canEdit = canEdit
        self._controller = .init(wrappedValue: UserACLController(spaceId: spaceId, userId: acl.userId, level: acl.acl))
    }
    var body: some View {
        HStack {
            UserDetailView(acl.profile)
            Spacer()
            if acl.acl == .owner {
                Text("Owner")
            } else if canEdit {
                ACLPicker(acl: $controller.level)
            } // otherwise, display nothing
        }.padding(.vertical, 5)
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
