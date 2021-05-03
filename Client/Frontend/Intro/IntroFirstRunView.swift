//
//  IntroFirstRunView.swift
//  Client
//

import SwiftUI
import Shared
import NeevaSupport

struct IntroFirstRunView: View {
    var buttonAction: (_:FirstRunButtonActions)->Void
    
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
                .font(Font.custom("Roobert-Light", size: 48))
                .foregroundColor(Color(UIColor.Neeva.Gray20))
                .padding(.top, 40)

            }
            VStack(){
                ZStack(){
                    HStack(){
                        Text("Sign In")
                        Spacer()
                        Symbol.neeva(.arrowRight, size: 22, weight: .medium)
                    }
                    .padding(EdgeInsets(top: 23, leading: 40, bottom: 23, trailing: 40))
                }
                .foregroundColor(Color(UIColor.Neeva.BrandCharcoal))
                .background(Color(UIColor.Neeva.BrandPolar))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color(UIColor.Neeva.Gray70), radius: 1, x: 1, y: 1)
                .padding(.top, 40)
                .onTapGesture(perform: {
                    buttonAction(FirstRunButtonActions.signin)
                })

                ZStack(){
                    HStack(){
                        Text("Sign Up")
                        Spacer()
                        Symbol.neeva(.arrowUpRight, size: 22, weight: .medium)
                    }
                    .padding(EdgeInsets(top: 23, leading: 40, bottom: 23, trailing: 40))
                }
                .foregroundColor(Color(UIColor.Neeva.White))
                .background(Color(UIColor.Neeva.BrandBlue))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .shadow(color: Color(UIColor.Neeva.Gray70), radius: 1, x: 1, y: 1)
                .padding(.top, 20)
                .onTapGesture(perform: {
                    buttonAction(FirstRunButtonActions.signup)
                })
            }
            .font(Font.custom("Roobert-SemiBold", size: 18))

            Text("Skip to browser without Neeva search")
                .underline()
                .font(Font.custom("Roobert-Regular", size: 16))
                .foregroundColor(Color(UIColor.Neeva.Gray20))
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                .onTapGesture(perform: {
                    buttonAction(FirstRunButtonActions.skipToBrowser)
                })
            Spacer()
        }
        .padding(35)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.Neeva.BrandBeige))
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
