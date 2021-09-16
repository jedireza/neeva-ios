// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct IntroFirstRunView: View {
    var buttonAction: (FirstRunButtonActions) -> Void
    let smallSizeScreen: CGFloat = 375.0

    @State var marketingEmailOptOut = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { buttonAction(.skipToBrowser) }) {
                    Symbol(decorative: .xmark, size: 20, weight: .semibold)
                        .foregroundColor(Color.ui.gray60)
                }
            }
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
                Button(action: { buttonAction(.signupWithApple(marketingEmailOptOut, nil)) }) {
                    HStack {
                        Image("apple")
                            .renderingMode(.template)
                            .padding(.leading, 28)
                        Spacer()
                        Text("Sign up with Apple")
                        Spacer()
                        Spacer()
                    }
                    .foregroundColor(.brand.white)
                    .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
                }
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
                .padding(.top, 40)

                Button(action: { buttonAction(.signupWithOther) }) {
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

            Button(action: { buttonAction(.signin) }) {
                (Text("Already have an account? ")
                    .foregroundColor(Color.ui.gray50)
                    + Text("Sign In").foregroundColor(Color.ui.gray20).fontWeight(.medium))
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Sign In")
            }
            .padding(.bottom, 30)
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
}

struct IntroFirstRunView_Previews: PreviewProvider {
    static var previews: some View {
        IntroFirstRunView { _ in
            print("action button pressed")
        }
    }
}
