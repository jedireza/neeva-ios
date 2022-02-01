// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CheatsheetTooltipPopoverView: View {
    @Environment(\.colorScheme) var colorScheme

    var isDarkMode: Bool { colorScheme == .dark }
    static let backgroundColorMode: WithPopoverColorMode = .dyanmicBackground(.brand.blue, .brand.variant.polar)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Try the Cheatsheet!")
                .withFont(.headingMedium)
                .foregroundColor(isDarkMode ? Color(hex: 0x000000) : Color.brand.white)
            Text("Tap on the Neeva logo to bring it up")
                .withFont(.bodyLarge)
                .foregroundColor(isDarkMode ? .brand.charcoal : .brand.offwhite)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 20)
    }
}

struct CheatsheetTooltipPopover_Previews: PreviewProvider {
    static var previews: some View {
        CheatsheetTooltipPopoverView()
    }
}
