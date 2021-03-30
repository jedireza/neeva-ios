//
//  File.swift
//  
//
//  Created by Eduardo Olivos Yaya on 26/03/21.
//

import SwiftUI

struct CreateSpaceView: View {
    @State private var isEditing = false
    @State private var spaceName = ""
    let onDismiss: ((CreateSpaceMutation.Data?, String) -> ())

    public init(onDismiss: @escaping ((CreateSpaceMutation.Data?, String) -> ())) {
        self.onDismiss = onDismiss
    }

    var body: some View{
        VStack {
            HStack(alignment: .top){
                Text("Create Space")
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                Spacer()
                Button(action: { onDismiss(nil, "") }) {
                    Image(systemName: "xmark")
                        .accessibilityLabel("Close Add to Space")
                        .foregroundColor(Color.gray)
                }
            }.padding(EdgeInsets(top: 28, leading: 17.5, bottom: 6, trailing: 17.5))
            
            HStack{
                TextField("Space name", text: $spaceName)
                if (self.isEditing) {
                    Image(systemName: "xmark.circle.fill")
                                    .imageScale(.medium)
                                    .foregroundColor(Color(.systemGray3))
                                    .padding(3)
                                    .onTapGesture {
                                        withAnimation {
                                            self.spaceName = ""
                                          }
                                    }
                }
            }
            .font(.system(size: 14))
            .padding(10)
            .padding(.leading, 17)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .padding(16)
            .onTapGesture {
                self.isEditing = true
            }
            Button(action: {
                if (spaceName.count > 0){
                    CreateSpaceMutation(name: spaceName).perform { result in
                        if case .success(let data) = result {
                            self.onDismiss(data, spaceName)
                        } else {
                            print("Error")
                            //TODO: display a toast of the failure
                        }
                    }
                }
            }) {
                Text("Save")
                    .fontWeight(.semibold)
                    .font(.system(size: 14))
                    .padding(10)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(Color(hex: 0x4078FB))
            .cornerRadius(40)
            .padding(.horizontal, 16)
            Spacer()
        }
    }
}
struct CreateSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSpaceView(onDismiss: {_,_  in })
    }
}


