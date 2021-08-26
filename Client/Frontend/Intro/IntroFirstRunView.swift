// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct IntroFirstRunView: View {
    var buttonAction: (FirstRunButtonActions) -> Void
    let smallSizeScreen: CGFloat = 375.0

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
                //Image("neeva-letter-logo")
                VStack(alignment: .leading) {
                    Text("Welcome to Neeva,")
                    Text("the only ad-free,")
                    Text("private search engine")
                }
                .font(
                    .roobert(.light, size: UIScreen.main.bounds.width <= smallSizeScreen ? 28 : 32)
                )
                .foregroundColor(Color.ui.gray20)
                .padding(.top, 40)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Neeva. Ad-free private search that puts you first")
            .accessibilityAddTraits(.isHeader)

            Image("woman-at-cafe")
                .resizable()
                .aspectRatio(contentMode: .fit)

            VStack {
                Button(action: { buttonAction(.signupWithApple) }) {
                    HStack {
                        Spacer()
                        Image("apple")
                            .renderingMode(.template)
                        Text("Sign up with Apple")
                        Spacer()
                    }
                    .foregroundColor(Color.white)
                    .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
                }
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
                .padding(.top, 20)

                Button(action: { buttonAction(.signupWithOther) }) {
                    HStack {
                        Spacer()
                        Text("Other Options")
                            .foregroundColor(.brand.white)
                        Spacer()
                    }
                    .foregroundColor(.brand.white)
                    .padding(EdgeInsets(top: 23, leading: 0, bottom: 23, trailing: 0))
                }
                .background(Color.brand.blue)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
                .padding(.top, 10)
            }
            .font(.roobert(.semibold, size: 18))

            Button(action: { buttonAction(.signin) }) {
                (Text("Already have an account? ").foregroundColor(Color.ui.gray50) +
                    Text("Log In").foregroundColor(Color.ui.gray20).fontWeight(.medium))
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 26)

            Spacer()
        }
        .padding(35)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brand.beige)
        .ignoresSafeArea(.all)
        .colorScheme(.light)
        .onAppear(perform: logImpression)
    }

    func logImpression() {
        ClientLogger.shared.logCounter(
            .FirstRunImpression, attributes: [ClientLogCounterAttribute]())
        Defaults[.firstRunSeenAndNotSignedIn] = true
    }
}

struct IntroFirstRunView_Previews: PreviewProvider {
    static var previews: some View {
        IntroFirstRunView { _ in
            print("action button pressed")
        }
    }
}
