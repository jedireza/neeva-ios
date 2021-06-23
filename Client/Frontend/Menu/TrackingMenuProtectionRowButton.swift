// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

public struct TrackingMenuProtectionRowButton: View {

    @Binding var isTrackingProtectionEnabled: Bool

    public var body: some View {
        Toggle(isOn: $isTrackingProtectionEnabled) {
            VStack(alignment: .leading) {
                Text("Tracking Prevention")
                    .font(.system(size: NeevaUIConstants.trackingMenuFontSize))
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
        TrackingMenuProtectionRowButton(isTrackingProtectionEnabled: .constant(true))
        TrackingMenuProtectionRowButton(isTrackingProtectionEnabled: .constant(false))
    }
}
