// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

public struct TrackingMenuProtectionRowButton: View {

    @Binding var preventTrackers: Bool

    public var body: some View {
        Toggle(isOn: $preventTrackers) {
            VStack(alignment: .leading) {
                Text("Tracking Prevention")
                    .withFont(.bodyLarge)
                Text("Website not working? Try disabling")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
            }
        }
        .applyNeevaMenuPanelSpec()
        .accessibilityIdentifier("TrackingMenu.TrackingMenuProtectionRow")
        .applyToggleStyle()
    }
}

struct TrackingMenuProtectionRowButton_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuProtectionRowButton(preventTrackers: .constant(true))
        TrackingMenuProtectionRowButton(preventTrackers: .constant(false))
    }
}
