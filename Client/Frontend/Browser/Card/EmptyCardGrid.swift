// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
