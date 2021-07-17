// Copyright Neeva. All rights reserved.

import UIKit
import SwiftUI

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

            Button(action: {
                UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/neeva-browser-search-engine/id1543288638")!)
            }, label: {
                HStack {
                    (Text("Download Now").underline().fontWeight(.semibold) +
                        Text(" for a \nbetter search experience").foregroundColor(Color(UIColor.link))).multilineTextAlignment(.center)

                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
