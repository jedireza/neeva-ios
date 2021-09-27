// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack {
            VStack { Divider().background(Color.ui.gray96) }.padding(.trailing, 20)
            Spacer()
            Text("OR")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.ui.gray30)
            Spacer()
            VStack { Divider().background(Color.ui.gray96) }.padding(.leading, 20)
        }
    }
}

public struct EmailForm: View {
    @Binding private var email: String
    var action: () -> Void

    init(email: Binding<String>, action: @escaping () -> Void) {
        self._email = email
        self.action = action
    }

    public var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(Color(UIColor.systemGray5), style: StrokeStyle(lineWidth: 1.0))
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: action) {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Continue")
                    Symbol(decorative: .arrowRight)
                    Spacer()
                }
                .foregroundColor(.brand.white)
                .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
            }
            .background(Color.brand.blue)
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
            .padding(.top, 20)
            .font(.roobert(.semibold, size: 18))
        }
    }
}

struct OtherOptionsPage: View {
    var buttonAction: (FirstRunButtonActions) -> Void
    @Binding var marketingEmailOptOut: Bool
    @State var email = ""

    var body: some View {
        VStack {
            Group {
                FirstRunCloseButton(
                    action: {
                        buttonAction(.skipToBrowser)
                        logOtherOptionsSkipToBrowser()
                    }
                )
                Text("Join Neeva")
                    .font(.roobert(.medium, size: 20))
                    .padding(.top, 20)
            }
            Spacer()
            EmailForm(
                email: $email,
                action: { buttonAction(.oktaSignup(email, marketingEmailOptOut)) }
            )
            Spacer()
            OrDivider()
            Spacer()
            Group {
                SignUpWithAppleButton(
                    action: {
                        logOtherOptionsSignUpWithAppleClick()
                        buttonAction(.signupWithApple(marketingEmailOptOut, nil))
                    }
                )

                SignUpWithGoogleButton(
                    action: {
                        logOtherOptionsSignUpWithGoogleClick()
                        buttonAction(.oauthWithProvider(.google, marketingEmailOptOut, ""))
                    }
                ).padding(.top, 10)

                SignUpWithMicrosoftButton(
                    action: {
                        logOtherOptionsSignupWithMicrosoftClick()
                        buttonAction(.oauthWithProvider(.microsoft, marketingEmailOptOut, ""))
                    }
                ).padding(.top, 10)
            }
            Spacer()
            Spacer()
            SignInButton(action: { buttonAction(.signin) })
        }
        .padding(35)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brand.offwhite)
        .ignoresSafeArea(.all)
        .colorScheme(.light)
    }

    func logOtherOptionsSignUpWithAppleClick() {
        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthOptionSignupWithApple,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .OptionSignupWithApple,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }

    func logOtherOptionsSignUpWithGoogleClick() {
        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthOptionSignupWithGoogle,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .OptionSignupWithGoogle,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }

    func logOtherOptionsSignupWithMicrosoftClick() {
        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthOptionSignupWithMicrosoft,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .OptionSignupWithMicrosoft,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }

    func logOtherOptionsSkipToBrowser() {
        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthOptionClosePanel,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .OptionClosePanel,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }
}
