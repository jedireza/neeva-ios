//
//  IntroFirstRunView.swift
//  Client
//

import SwiftUI
import Shared

struct IntroFirstRunView: View {
    var buttonAction: (FirstRunButtonActions) -> Void
    let smallSizeScreen: CGFloat = 375.0

    var body: some View {
        VStack() {
            Spacer()
            VStack(alignment: .leading){
                Image("neeva-letter-logo")
                VStack(alignment: .leading) {
                    Text("Ad-free,")
                    Text("private search")
                    Text("that puts you")
                    Text("first.")
                }
                .font(Font.custom("Roobert-Light", size: UIScreen.main.bounds.width <= smallSizeScreen ? 36 : 48))
                .foregroundColor(Color.Neeva.UI.Gray20)
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
                        Symbol(.arrowRight, size: 22)
                    }
                    .padding(EdgeInsets(top: 23, leading: 40, bottom: 23, trailing: 40))
                    .foregroundColor(Color.Neeva.Brand.Charcoal)
                }
                .background(Color.Neeva.Brand.Polar)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color.Neeva.UI.Gray70, radius: 1, x: 1, y: 1)
                .padding(.top, 40)

                Button(action: { buttonAction(.signup) }) {
                    HStack {
                        Text("Sign Up")
                        Spacer()
                        Symbol(.arrowUpRight, size: 22)
                    }
                    .padding(EdgeInsets(top: 23, leading: 40, bottom: 23, trailing: 40))
                    .foregroundColor(Color.Neeva.Brand.White)
                }
                .background(Color.Neeva.Brand.Blue)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color.Neeva.UI.Gray70, radius: 1, x: 1, y: 1)
                .padding(.top, 20)
            }
            .font(Font.custom("Roobert-SemiBold", size: 18))

            Button(action: { buttonAction(.skipToBrowser) }) {
                Text("Skip to browser without Neeva search")
                    .underline()
                    .font(Font.custom("Roobert-Regular", size: 16))
                    .foregroundColor(Color.Neeva.UI.Gray20)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)

            Spacer()
        }
        .padding(35)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Neeva.Brand.Beige)
        .ignoresSafeArea(.all)
    }
}

struct IntroFirstRunView_Previews: PreviewProvider {
    static var previews: some View {
        IntroFirstRunView { _ in
            print("action button pressed")
        }
    }
}
