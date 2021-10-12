// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct HTTPAuthPromptOverlayView: View {
    let url: String

    /// Passes a `username` and `password` in the completion handler
    let onSubmit: (String, String) -> Void
    let onCancel: () -> Void

    @State var username = ""
    @State var password = ""

    public var body: some View {
        GroupedStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sign in to:")
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)

                Text(url)
                    .withFont(.labelMedium)
                    .truncationMode(.middle)
                    .foregroundColor(.secondaryLabel)
            }.padding(.bottom, 14)

            SingleLineTextField(
                icon: Symbol(decorative: .personFill, style: .labelLarge), placeholder: "Username",
                text: $username
            )
            .accessibilityIdentifier("Auth_Username_Field")
            .accessibility(label: Text("Username"))

            SingleLineTextField(
                icon: Symbol(decorative: .lockFill, style: .labelLarge), placeholder: "Password",
                text: $password, alwaysShowClearButton: false, secureText: true
            )
            .padding(.bottom)
            .accessibilityIdentifier("Auth_Password_Field")
            .accessibility(label: Text("Password"))

            GroupedCellButton("Submit", style: .labelLarge) {
                onSubmit(username, password)
            }
            .accessibilityIdentifier("Auth_Submit")
            .accessibility(label: Text("Submit"))

            GroupedCellButton("Cancel", style: .labelLarge, action: onCancel)
        }
    }
}

struct HTTPAuthPromptOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        HTTPAuthPromptOverlayView(url: "neeva.com", onSubmit: { _, _ in }, onCancel: {})
    }
}
