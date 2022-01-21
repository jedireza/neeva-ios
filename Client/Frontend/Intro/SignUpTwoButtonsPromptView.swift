// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AuthenticationServices
import Shared
import SwiftUI

struct SignUpTwoButtonsPromptViewOverlayContent: View {
    var query: String
    var skippable: Bool
    var openOtherSignUpOption: (Bool) -> Void
    var openSignIn: () -> Void

    var body: some View {
        SignUpTwoButtonsPromptView(
            query: query, skippable: skippable, openOtherSignUpOption: openOtherSignUpOption,
            openSignIn: openSignIn
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
    var openSignIn: () -> Void

    @State var marketingEmailOptOut: Bool = false

    var maxQueryCharacterCount = 28

    var skipButton: some View {
        FirstRunCloseButton {
            hideOverlay()
            ClientLogger.shared.logCounter(
                .PreviewPromptClose,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    var nonSkippableHeader: some View {
        VStack {
            Text("Thank you for trying Neeva!")
                .font(.roobert(size: 24))
                .padding(.bottom, 6)
                .padding(.top, 4)

            VStack(spacing: 2) {
                Text("Create your account for continued")
                Text("access and to see results for")
                Text(
                    "“\(query.count > maxQueryCharacterCount ? query.prefix(maxQueryCharacterCount) + "..." : query)“"
                )
                .foregroundColor(.primary)
                .lineLimit(1)
                .withFont(unkerned: .headingLarge)
            }
            .withFont(unkerned: .bodyLarge)
            .foregroundColor(.secondaryLabel)
        }
    }

    var skippableHeader: some View {
        VStack(spacing: 0) {
            Text("See results for")
                .font(.roobert(size: 24))
                .foregroundColor(Color(light: Color.brand.charcoal, dark: Color.brand.offwhite))
            Text(
                "“\(query.count > maxQueryCharacterCount ? query.prefix(maxQueryCharacterCount) + "..." : query)”"
            )
            .font(.roobert(.medium, size: 24))
            .foregroundColor(.primary)
            .lineLimit(1)
            Text("Create your Neeva account.")
                .withFont(.bodyLarge)
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 4)
        }
        .padding(.top, 8)
    }

    var footer: some View {
        VStack {
            Text("By creating your Neeva account you acknowledge")
                .padding(.bottom, 2)
            HStack(spacing: 0) {
                Text("Neeva's ")
                Button(action: {
                    hideOverlay()
                    openInNewTab(NeevaConstants.appTermsURL, false)
                }) {
                    Text("Terms of Service").underline()
                }
                Text(" and ")
                Button(action: {
                    hideOverlay()
                    openInNewTab(NeevaConstants.appPrivacyURL, false)
                }) {
                    Text("Privacy Policy").underline()
                }
            }
        }
        .foregroundColor(.secondary)
        .font(.system(size: 13))
        .padding(.bottom, 26)
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
                                ClientLogger.shared.logCounter(
                                    .PreviewPromptSignupWithApple,
                                    attributes: EnvironmentHelper.shared.getFirstRunAttributes())
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
        .padding(.vertical)
    }

    var otherSignUpOptionsButton: some View {
        Button(action: {
            ClientLogger.shared.logCounter(
                .PreviewPromptOtherSignupOptions,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
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
                    .withFont(.bodyMedium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 25)
    }

    var signInButton: some View {
        Button(action: {
            hideOverlay()
            openSignIn()
            ClientLogger.shared.logCounter(
                .PreviewPromptSignIn, attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }) {
            HStack(spacing: 0) {
                Text("Already have an account? ")
                Text("Sign In").withFont(.labelMedium).padding(.leading, 2)
            }
            .font(.system(size: 14))
            .foregroundColor(.primary)
            .accessibilityLabel("Sign In")
        }
        .padding(.bottom, 10)
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
                footer
                signInButton
            }
        }
        .frame(height: horizontalSizeClass == .regular || verticalSizeClass == .regular ? 530 : 320)
    }
}

struct SignUpTwoButtonsPromptView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpTwoButtonsPromptView(
            query: "react hook", skippable: true, openOtherSignUpOption: { _ in }, openSignIn: {})
    }
}
