// Copyright Neeva. All rights reserved.

import AuthenticationServices
import Shared
import SwiftUI

struct SignUpTwoButtonsPromptViewOverlayContent: View {
    var query: String
    var skippable: Bool
    var openOtherSignUpOption: (Bool) -> Void

    var body: some View {
        SignUpTwoButtonsPromptView(
            query: query, skippable: skippable, openOtherSignUpOption: openOtherSignUpOption
        )
        .overlayIsFixedHeight(isFixedHeight: true)
        .background(Color(.systemBackground))
    }
}

struct SignUpTwoButtonsPromptView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.hideOverlay) private var hideOverlay
    @Environment(\.openInNewTab) var openInNewTab

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var query: String
    var skippable: Bool
    var openOtherSignUpOption: (Bool) -> Void

    @State var marketingEmailOptOut: Bool = false

    var skipButton: some View {
        Button(action: hideOverlay) {
            HStack {
                Spacer()
                Text("Skip for now")
                    .withFont(.bodyMedium)
                    .font(.system(size: 14))
                    .foregroundColor(Color(light: Color.brand.blue, dark: Color.brand.variant.blue))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    var nonSkippableHeader: some View {
        VStack {
            VStack {
                Text("Thank you for trying")
                Text("Neeva!")
            }
            .font(.roobert(size: 32))
            .padding(.bottom, 6)
            .padding(.top, 4)

            VStack(spacing: 2) {
                Text("Create your account for continued")
                Text("access and to see results for")
                Text("“\(query)“")
                    .withFont(.labelLarge, weight: .medium)
                    .foregroundColor(Color(light: Color(hex: 0x636366), dark: Color(hex: 0xAEAEB2)))
                    .lineLimit(1)
            }
            .withFont(unkerned: .bodyLarge)
            .foregroundColor(.secondaryLabel)
        }
    }

    var skippableHeader: some View {
        VStack {
            Text("Welcome to Neeva. Ad-free, private search.")
                .font(.roobert(size: 16))
                .foregroundColor(Color(light: Color.brand.charcoal, dark: Color.brand.offwhite))
                .padding(.top, 10)

            VStack {
                Text("See results for")
                    .font(.roobert(size: 24))
                    .foregroundColor(Color(light: Color.brand.charcoal, dark: Color.brand.offwhite))
                Text("“\(query)”")
                    .font(.roobert(.medium, size: 24))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .padding(.top, 8)
        }
    }

    var signUpWithAppleButton: some View {
        SignInWithAppleButton(
            .signUp,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let auth):
                    switch auth.credential {
                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
                        // redirect and create account
                        let token = appleIDCredential.identityToken

                        if token != nil {
                            if let authStr = String(data: token!, encoding: .utf8) {
                                let authURL = NeevaConstants.appleAuthURL(
                                    serverAuthCode: authStr,
                                    marketingEmailOptOut: self.marketingEmailOptOut,
                                    signup: true)
                                hideOverlay()
                                openInNewTab(authURL, false)
                            }
                        }
                        break
                    default:
                        break
                    }
                default:
                    break
                }
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
        .clipShape(RoundedRectangle(cornerRadius: 100))
        .frame(width: 340, height: 55, alignment: .center)
        .padding()
    }

    var otherSignUpOptionsButton: some View {
        Button(action: {
            hideOverlay()
            openOtherSignUpOption(marketingEmailOptOut)
        }) {
            HStack {
                Spacer()
                Text("Other sign up options")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.brand.white)
                Spacer()
            }
            .foregroundColor(.brand.white)
            .padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
        }
        .background(Color(light: Color.brand.blue, dark: Color.brand.variant.blue))
        .clipShape(RoundedRectangle(cornerRadius: 100))
        .frame(width: 340, height: 30)
    }

    var emailOptionButton: some View {
        Button(action: { marketingEmailOptOut.toggle() }) {
            HStack {
                marketingEmailOptOut
                    ? Symbol(decorative: .circle, size: 20)
                        .foregroundColor(Color.tertiaryLabel)
                    : Symbol(decorative: .checkmarkCircleFill, size: 20)
                        .foregroundColor(Color.blue)
                Text("Send me product & privacy tips")
                    .font(.roobert(size: 13))
                    .foregroundColor(Color(light: Color(hex: 0x636366), dark: Color(hex: 0xAEAEB2)))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 30)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if skippable {
                    skipButton
                }

                Image("neevaMenuIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .padding(.top, skippable ? 0 : 16)

                if skippable {
                    skippableHeader
                } else {
                    nonSkippableHeader
                }
                signUpWithAppleButton
                otherSignUpOptionsButton
                emailOptionButton
            }
        }
        .frame(height: horizontalSizeClass == .regular || verticalSizeClass == .regular ? 430 : 300)
    }
}

struct SignUpTwoButtonsPromptView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpTwoButtonsPromptView(
            query: "react hook", skippable: true, openOtherSignUpOption: { _ in })
    }
}
