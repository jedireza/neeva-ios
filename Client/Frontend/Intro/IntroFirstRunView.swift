// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct IntroFirstRunView: View {
    var buttonAction: (FirstRunButtonActions) -> Void
    let smallSizeScreen: CGFloat = 375.0

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                Image("neeva-letter-logo")
                VStack(alignment: .leading) {
                    Text("Ad-free,")
                    Text("private search")
                    Text("that puts you")
                    Text("first.")
                }
                .font(
                    .roobert(.light, size: UIScreen.main.bounds.width <= smallSizeScreen ? 36 : 48)
                )
                .foregroundColor(Color.ui.gray20)
                .padding(.top, 40)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Neeva. Ad-free private search that puts you first")
            .accessibilityAddTraits(.isHeader)

            VStack {
                Button(action: { buttonAction(.signin) }) {
                    HStack {
                        Text("Sign In")
                        Spacer()
                        Symbol(decorative: .arrowRight, size: 22)
                    }
                    .padding(EdgeInsets(top: 23, leading: 40, bottom: 23, trailing: 40))
                    .foregroundColor(Color.brand.charcoal)
                }
                .background(Color.brand.polar)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
                .padding(.top, 40)

                Button(action: { buttonAction(.signup) }) {
                    HStack {
                        Text("Sign Up")
                        Spacer()
                        Symbol(decorative: .arrowUpRight, size: 22)
                    }
                    .padding(EdgeInsets(top: 23, leading: 40, bottom: 23, trailing: 40))
                    .foregroundColor(.brand.white)
                }
                .background(Color.brand.blue)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color.ui.gray70, radius: 1, x: 0, y: 1)
                .padding(.top, 20)
            }
            .font(.roobert(.semibold, size: 18))

            Button(action: { buttonAction(.skipToBrowser) }) {
                Text("Skip to browser without Neeva search")
                    .underline()
                    .font(.roobert(size: 16))
                    .foregroundColor(Color.ui.gray20)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)

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
