// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

public struct AuthButton: View {
    var action: () -> Void
    var icon: String
    var label: String
    var textColor: Color
    var backgroundColor: Color
    var tintIcon: Bool = false

    public var body: some View {
        Button(action: action) {
            HStack {
                Image(icon)
                    .renderingMode(tintIcon ? .template : .none)
                    .padding(.leading, 28)
                Spacer()
                Text(label)
                Spacer()
                Spacer()
            }
            .foregroundColor(textColor)
            .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 100))
        .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
        .font(.roobert(.semibold, size: 18))
    }
}

public struct SignUpWithAppleButton: View {
    var action: () -> Void
    @Binding public var onSignInMode: Bool

    public var body: some View {
        AuthButton(
            action: action,
            icon: "apple",
            label: "Sign \(onSignInMode ? "in" : "up") with Apple",
            textColor: .brand.white,
            backgroundColor: Color.black,
            tintIcon: true)
    }
}

public struct SignUpWithGoogleButton: View {
    var action: () -> Void
    @Binding public var onSignInMode: Bool

    public var body: some View {
        AuthButton(
            action: action,
            icon: "google_icon",
            label: "Sign \(onSignInMode ? "in" : "up") with Google",
            textColor: Color.ui.gray20,
            backgroundColor: .brand.white)
    }
}

public struct SignUpWithMicrosoftButton: View {
    var action: () -> Void
    @Binding public var onSignInMode: Bool

    public var body: some View {
        AuthButton(
            action: action,
            icon: "microsoft",
            label: "Sign \(onSignInMode ? "in" : "up") with Microsoft",
            textColor: Color.ui.gray20,
            backgroundColor: .brand.white)
    }
}

struct SignInButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            (Text("Already have an account? ")
                .foregroundColor(Color.ui.gray50)
                + Text("Sign In").foregroundColor(Color.ui.gray20).fontWeight(.medium))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .accessibilityLabel("Sign In")
        }
        .padding(.bottom, 10)
    }
}

struct SignUpButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            (Text("Don't have an account? ")
                .foregroundColor(Color.ui.gray50)
                + Text("Sign Up").foregroundColor(Color.ui.gray20).fontWeight(.medium))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .accessibilityLabel("Sign Up")
        }
        .padding(.bottom, 10)
    }
}

struct FirstRunCloseButton: View {
    var action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Symbol(decorative: .xmark, size: 20, weight: .semibold)
                    .foregroundColor(Color.ui.gray60)
            }
        }
    }
}

struct AuthButton_Previews: PreviewProvider {
    static var previews: some View {
        SignUpWithAppleButton(action: {}, onSignInMode: .constant(false))
    }
}
