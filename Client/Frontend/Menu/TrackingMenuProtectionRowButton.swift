//
//  TrackingMenuProtectionRowButton.swift
//  Client
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//
import SwiftUI

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
                    .font(.system(size: NeevaUIConstants.menuFontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("If this site appears broken, try disabling.")
                    .foregroundColor(Color(UIColor.PopupMenu.secondaryTextColor))
                    .font(.system(size: NeevaUIConstants.trackingMenuSubtextFontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.layoutPriority(1)
            Toggle("", isOn: $isTrackingProtectionOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                .onChange(of: isTrackingProtectionOn){ value in
                    self.toggleAction()
                }.accessibilityHint("Double tap to toggle block tracking")
        }.applyNeevaMenuPanelSpec()
        .accessibilityIdentifier("TrackingMenu.TrackingMenuProtectionRow")
    }
}

struct TrackingMenuProtectionRowButton_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuProtectionRowButton(name: "Test", toggleAction: {return}, isTrackingProtectionOn: true)
    }
}
