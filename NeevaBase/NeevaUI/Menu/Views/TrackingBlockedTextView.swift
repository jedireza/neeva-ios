//
//  TrackingBlockedTextView.swift
//  Client
//
//  Created by Stuart Allen on 3/20/21.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import SwiftUI

public struct TrackingBlockedTextView: View {
    
    let displayText: String
    
    public var body: some View {

        Text(displayText)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(Color(UIColor.theme.popupMenu.secondaryTextColor))
          .font(.system(size: NeevaUIConstants.trackingMenuFontSize))
        
    }
}
struct TrackingBlockedTextView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingBlockedTextView(displayText: "")
    }
}

