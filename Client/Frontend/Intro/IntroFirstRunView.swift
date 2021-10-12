// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct FirstRunHomePage: View {
    var buttonAction: (FirstRunButtonActions) -> Void
    @Binding var marketingEmailOptOut: Bool
    @Binding var onOtherOptionsPage: Bool
    @Binding var onSignInMode: Bool

    let smallSizeScreen: CGFloat = 375.0

    var body: some View {
        VStack {
            FirstRunCloseButton(
                action: {
                    buttonAction(.skipToBrowser)
                    logFirstRunSkipToBrowser()
                }
            )
            Spacer()
            VStack(alignment: .leading) {
                Image("neeva-letter-only")
                VStack(alignment: .leading) {
                    Text("Welcome to")
                    Text("Neeva, the only")
                    Text("ad-free, private")
                    Text("search engine")
                }
                .font(
                    .roobert(.light, size: UIScreen.main.bounds.width <= smallSizeScreen ? 32 : 42)
                )
                .foregroundColor(Color.ui.gray20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Welcome to Neeva, the only ad-free, private search engine")
            .accessibilityAddTraits(.isHeader)

            VStack {
                SignUpWithAppleButton(
                    action: {
                        logFirstRunSignUpWithAppleClick()
                        buttonAction(.signupWithApple(marketingEmailOptOut, nil))
                    },
                    onSignInMode: $onSignInMode
                )
                .padding(.top, 40)

                Button(action: {
                    logFirstRunOtherSignupOption()
                    onOtherOptionsPage = true
                }) {
                    HStack {
                        Spacer()
                        Text("Other sign up options")
                            .foregroundColor(.brand.white)
                        Spacer()
                    }
                    .foregroundColor(.brand.white)
                    .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
                }
                .background(Color.brand.blue)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
                .padding(.top, 20)
            }
            .font(.roobert(.semibold, size: 18))

            Button(action: { marketingEmailOptOut.toggle() }) {
                HStack {
                    marketingEmailOptOut
                        ? Symbol(decorative: .circle, size: 20)
                            .foregroundColor(Color.tertiaryLabel)
                        : Symbol(decorative: .checkmarkCircleFill, size: 20)
                            .foregroundColor(Color.blue)
                    Text("Send me product & privacy tips")
                        .font(.roobert(size: 13))
                        .foregroundColor(Color.ui.gray20)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 20)

            Spacer()

            SignInButton(action: {
                logFirstRunSignin()
                onOtherOptionsPage = true
                onSignInMode = true
            })
            .padding(.bottom, 20)
        }
        .padding(35)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brand.offwhite)
        .ignoresSafeArea(.all)
        .colorScheme(.light)
        .onAppear(perform: logImpression)
    }

    func logImpression() {
        if Defaults[.introSeen] {
            // open by clicking sign in beyond first run
            ClientLogger.shared.logCounter(
                .AuthImpression, attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // at first run screen
            if !Defaults[.firstRunImpressionLogged] {
                ClientLogger.shared.logCounter(
                    .FirstRunImpression,
                    attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                Defaults[.firstRunImpressionLogged] = true
            }
            Defaults[.firstRunSeenAndNotSignedIn] = true
        }
    }

    func logFirstRunSignUpWithAppleClick() {
        if onSignInMode {
            return
        }

        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthSignUpWithApple,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .FirstRunSignupWithApple,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }

    func logFirstRunSkipToBrowser() {
        if onSignInMode {
            return
        }

        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthClose,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            ClientLogger.shared.logCounter(
                .FirstRunSkipToBrowser,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }

    func logFirstRunOtherSignupOption() {
        if onSignInMode {
            return
        }

        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthOtherSignUpOptions,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .FirstRunOtherSignUpOptions,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
            Defaults[.firstRunPath] = "FirstRunOtherSignUpOptions"
        }
    }

    func logFirstRunSignin() {
        if Defaults[.introSeen] {
            // beyond first run screen
            ClientLogger.shared.logCounter(
                .AuthSignin,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        } else {
            // first run screen
            ClientLogger.shared.logCounter(
                .FirstRunSignin,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
            Defaults[.firstRunPath] = "FirstRunSignin"
        }
    }
}

struct IntroFirstRunView: View {
    var buttonAction: (FirstRunButtonActions) -> Void

    @State var marketingEmailOptOut = false
    @State var onOtherOptionsPage = false
    @State var onSignInMode = false

    var body: some View {
        if onOtherOptionsPage {
            OtherOptionsPage(
                buttonAction: buttonAction,
                marketingEmailOptOut: $marketingEmailOptOut,
                onSignInMode: $onSignInMode
            )
        } else {
            FirstRunHomePage(
                buttonAction: buttonAction,
                marketingEmailOptOut: $marketingEmailOptOut,
                onOtherOptionsPage: $onOtherOptionsPage,
                onSignInMode: $onSignInMode)
        }
    }
}

struct IntroFirstRunView_Previews: PreviewProvider {
    static var previews: some View {
        IntroFirstRunView { _ in
            print("action button pressed")
        }
    }
}
