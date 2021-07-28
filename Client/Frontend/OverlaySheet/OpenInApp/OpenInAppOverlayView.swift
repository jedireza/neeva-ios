// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI
import UIKit

struct OpenInAppView: View {
    let url: URL
    let onOpen: () -> Void
    let onDismiss: () -> Void

    public var body: some View {
        GroupedStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Open link in external app?")
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)

                Text(url.absoluteString)
                    .withFont(.labelMedium)
                    .truncationMode(.middle)
                    .foregroundColor(.secondaryLabel)
            }.padding(.bottom, 14)

            GroupedCellButton("Open", action: onOpen)
                .accessibilityIdentifier("ConfirmOpenInApp")

            GroupedCellButton("Cancel", style: .labelLarge, action: onDismiss)
                .accessibilityIdentifier("CancelOpenInApp")
        }
    }
}

struct OpenInAppView_Previews: PreviewProvider {
    static var previews: some View {
        OpenInAppView(url: URL(string: "example.com")!, onOpen: {}, onDismiss: {})
    }
}
