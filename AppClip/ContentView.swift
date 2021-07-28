// Copyright Neeva. All rights reserved.

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                Image("neeva-logo")
                Text("Neeva")
                    .foregroundColor(Color("Blue"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            Button(
                action: {
                    UIApplication.shared.open(URL(string: "neeva://finish-log-in")!)
                },
                label: {
                    (Text("You're logged in! ")
                        + Text("Open Neeva").underline().fontWeight(.semibold)
                        + Text(" for a \nbetter search experience").foregroundColor(
                            Color(UIColor.link))).multilineTextAlignment(.center)
                })

            Button(
                action: {
                    UIApplication.shared.open(URL(string: "AppClipApp.neevaAppStorePageURL")!)
                },
                label: {
                    (Text("Don't have Neeva? ")
                        + Text("Download the app now!").underline().fontWeight(.semibold))
                        .multilineTextAlignment(.center)
                })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
