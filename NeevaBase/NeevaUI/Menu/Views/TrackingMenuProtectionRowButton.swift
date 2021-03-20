//
//  TrackingMenuProtectionRowButton.swift
//  Client
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//
import SwiftUI

public struct TrackingMenuProtectionRowButton: View {
    
    let buttonName: String
    
    @State private var trackingProtectionOn = true
    
    /// - Parameters:
    ///   - name: The display name of the button
    public init(name: String){
        self.buttonName = name
    }
    
    public var body: some View {
        Group{
            ZStack{
                VStack{
                    Text(buttonName)
                        .foregroundColor(Color(UIColor.theme.popupMenu.textColor))
                        .font(.system(size: NeevaUIConstants.menuFontSize))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("If this site appears broken, try disabling")
                        .foregroundColor(Color(UIColor.theme.popupMenu.secondaryTextColor))
                        .font(.system(size: NeevaUIConstants.trackingMenuSubtextFontSize))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Toggle("", isOn: $trackingProtectionOn)
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
            }
        }
        .padding(NeevaUIConstants.menuRowPadding)
        .frame(minWidth: 0, maxWidth: 310)
        .background(Color(UIColor.theme.popupMenu.foreground))
        .cornerRadius(NeevaUIConstants.menuCornerDefault)
    }
}

struct TrackingMenuProtectionRowButton_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuProtectionRowButton(name: "Test")
    }
}
