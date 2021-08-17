// Copyright Neeva. All rights reserved.

import SwiftUI

struct EmptyCardGrid: View {
    var body: some View {
        VStack {
            Image("EmptyTabTray")
            Text("Create and manage tabs")
                .withFont(.headingXLarge)
            Text("Tap + below to create a new tab")
                .withFont(.bodyMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.TrayBackground).ignoresSafeArea())
    }
}

struct EmptyCardGrid_Previews: PreviewProvider {
    static var previews: some View {
        EmptyCardGrid()
    }
}
