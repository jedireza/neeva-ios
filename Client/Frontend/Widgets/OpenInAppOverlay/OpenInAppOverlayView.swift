// Copyright Neeva. All rights reserved.

import UIKit
import SwiftUI
import Shared

struct OpenInAppView: View {
    let url: URL
    let onOpen: () -> ()
    let onDismiss: () -> ()

    public var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Open link in external app?")
                    .withFont(.bodyLarge)
                    .foregroundColor(.primary)

                Text(url.absoluteString)
                    .withFont(.labelMedium)
                    .truncationMode(.middle)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .center, spacing: 12) {
                OverlaySheetButton("Open", action: onOpen)
                    .accessibilityIdentifier("ConfirmOpenInApp")

                OverlaySheetButton("Cancel", action: onDismiss)
                    .accessibilityIdentifier("CancelOpenInApp")
            }
            .foregroundColor(.ui.adaptive.blue)
        }.padding()
    }
}

struct OpenInAppView_Previews: PreviewProvider {
    static var previews: some View {
        OpenInAppView(url: URL(string: "example.com")!, onOpen: {}, onDismiss: {})
    }
}
