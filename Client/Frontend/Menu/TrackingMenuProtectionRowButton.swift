// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

public struct TrackingMenuProtectionRowButton: View {

    /// - Parameters:
    ///   - name: The display name of the button
    ///   - toggleAction: function to call when toggling tracking protection
    ///   - isTrackingProtection: Original value and state change value for the tracking protection switch
    let name: String
    var toggleAction: () -> ()
    @State var isTrackingProtectionOn :Bool

    public var body: some View {
        HStack {
            VStack{
                Text(name)
                    .foregroundColor(Color(UIColor.PopupMenu.textColor))
                    .font(.system(size: NeevaUIConstants.trackingMenuFontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("If the site seems broken, try disabling")
                    .foregroundColor(Color(UIColor.PopupMenu.secondaryTextColor))
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.layoutPriority(1)
            Toggle("", isOn: $isTrackingProtectionOn)
                .onChange(of: isTrackingProtectionOn){ value in
                    self.toggleAction()
                }.accessibilityHint("Double tap to toggle block tracking")
        }.applyNeevaMenuPanelSpec()
        .accessibilityIdentifier("TrackingMenu.TrackingMenuProtectionRow")
        .applyToggleStyle()
    }
}

struct TrackingMenuProtectionRowButton_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuProtectionRowButton(name: "Test", toggleAction: {return}, isTrackingProtectionOn: true)
    }
}
