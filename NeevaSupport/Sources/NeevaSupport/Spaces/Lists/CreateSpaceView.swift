// Copyright Neeva. All rights reserved.

import Introspect
import SwiftUI

struct CreateSpaceView: View {
    @State private var isEditing = false
    @State private var spaceName = ""
    let onDismiss: (String) -> ()

    public init(onDismiss: @escaping (String) -> ()) {
        self.onDismiss = onDismiss
    }

    var body: some View{
        VStack {
            HStack{
                TextField("Space name", text: $spaceName)
                if (self.isEditing && !self.spaceName.isEmpty) {
                    Symbol.system(.xmarkCircleFill, size: 16, weight: .medium)
                        .foregroundColor(.tertiaryLabel)
                        .padding([.leading, .trailing], 2)
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
            .background(Color.quaternarySystemFill)
            .cornerRadius(20)
            .padding(16)
            .onTapGesture {
                self.isEditing = true
            }
            Button(action: {
                self.onDismiss(self.spaceName)
            }) {
                Text("Save")
                    .fontWeight(.semibold)
                    .font(.system(size: 14))
                    .padding(10)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(Color.Neeva.Brand.Blue)
            .cornerRadius(40)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        // Focus the text field automatically when loading this view. Unfortunately,
        // SwiftUI provides no way to do this, so we have to resort to using Introspect.
        // See https://github.com/siteline/SwiftUI-Introspect/issues/99 for why this is
        // here instead of right below the TextField() instantiation above.
        .introspectTextField { textField in
            textField.becomeFirstResponder()
        }
    }
}
struct CreateSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSpaceView(onDismiss: { _ in })
    }
}


