// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

public struct TrackingMenuProtectionRowButton: View {

    @Binding var preventTrackers: Bool

    public var body: some View {
        GroupedCell {
            Toggle(isOn: $preventTrackers) {
                VStack(alignment: .leading) {
                    Text("Tracking Prevention")
                        .withFont(.bodyLarge)
                    Text("Website not working? Try disabling")
                        .foregroundColor(.secondaryLabel)
                        .font(.footnote)
                }
            }
            .accessibilityIdentifier("TrackingMenu.TrackingMenuProtectionRow")
            .padding(.vertical, 12)
            .applyToggleStyle()
        }
    }
}

struct TrackingMenuProtectionRowButton_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuProtectionRowButton(preventTrackers: .constant(true))
        TrackingMenuProtectionRowButton(preventTrackers: .constant(false))
    }
}
