// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct RelatedSearchesView: View {
    let relatedSearches: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("People Also Search")
                .withFont(.headingXLarge)
                .padding(.bottom, 6)

            ForEach(relatedSearches, id: \.self) { search in
                QueryButtonView(query: search)
            }
        }
    }
}
