// Copyright Neeva. All rights reserved.

import SwiftUI

struct RelatedSearchesView: View {
    let relatedSearches: [String]
    let onDismiss: (() -> Void)?
    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        VStack(alignment: .leading) {
            Text("People Also Search")
                .withFont(.headingXLarge)
                .padding(.bottom, 6)
            
            ForEach(relatedSearches, id: \.self) { search in
                QueryButton(query: search, onDismiss: onDismiss)
            }
        }
    }
}
