// Copyright Neeva. All rights reserved.

import SwiftUI

struct EmptyCardGrid: View {
    var isIncognito: Bool = false

    var body: some View {
        VStack {
            Image(isIncognito ? "EmptyTabTrayIncognito" : "EmptyTabTray")
            Text("Create and manage\(isIncognito ? " incognito" : "") tabs")
                .withFont(.headingXLarge)
            Text("Tap + below to create a new tab")
                .withFont(.bodyMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyCardGrid_Previews: PreviewProvider {
    static var previews: some View {
        EmptyCardGrid()
    }
}
