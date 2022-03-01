// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

public struct WalletSequenceSiteHeader: View {
    let iconURL: URL
    let domain: String
    let trusted: Bool

    public init(iconURL: URL, domain: String, trusted: Bool) {
        self.iconURL = iconURL
        self.domain = domain
        self.trusted = trusted
    }

    public var body: some View {
        WebImage(url: iconURL)
            .resizable()
            .placeholder {
                Color.secondarySystemFill
            }
            .transition(.opacity)
            .scaledToFit()
            .frame(width: 48, height: 48)
            .background(Color.white)
            .clipShape(Circle())
        HStack {
            if trusted {
                Image("twitter-verified-large")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.ui.adaptive.blue)
                    .frame(width: 16, height: 16)
            }
            Text(domain)
                .withFont(.labelLarge)
                .foregroundColor(trusted ? .ui.adaptive.blue : .label)
        }
    }
}
