//
//  TrackingBlockedView.swift
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

public struct TrackingBlockedView: View {
    
    let trackerCount: Int
    let domainCount: Int
    let siteName: String
    
    /// - Parameters:
    ///   - trackerCount: The number of trackers blocked
    ///   - domainCount: The number of domains blocked
    public init(trackerCount: Int, domainCount: Int, siteName: String){
        self.trackerCount = trackerCount
        self.domainCount = domainCount
        self.siteName = siteName
    }
    
    public var body: some View {
        Group{
            VStack(spacing:10){
                Text("BLOCKED ON \(self.siteName.uppercased())")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(UIColor.theme.popupMenu.secondaryTextColor))
                    .font(.system(size: NeevaUIConstants.trackingMenuFontSize))
                HStack(spacing: 8) {
                    Text("\(self.trackerCount)")
                        .foregroundColor(Color.red)
                    Text("Trackers")
                        .foregroundColor(Color(UIColor.theme.popupMenu.secondaryTextColor))
                    Divider()
                    Text("\(self.domainCount)")
                        .foregroundColor(Color.red)
                    Text("Domains")
                        .foregroundColor(Color(UIColor.theme.popupMenu.secondaryTextColor))
                    Spacer()
                }
                .font(.system(size: NeevaUIConstants.trackingMenuBlockedFontSize))
                Text("HALL OF SHAME")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(UIColor.theme.popupMenu.secondaryTextColor))
                    .font(.system(size: NeevaUIConstants.trackingMenuFontSize))
                HStack(spacing: 8) {
                    TrackingBlameView(shameCount: 20, image:"menu-home-alt")
                    TrackingBlameView(shameCount:5, image:"menu-home-alt")
                    TrackingBlameView(shameCount:10, image:"menu-home-alt")
                    Spacer()
                }
            }
            .padding(NeevaUIConstants.menuInnerPadding)
        }
        .padding(NeevaUIConstants.menuInnerPadding)
        .frame(minWidth: 0, maxWidth: 310)
        .background(Color(UIColor.theme.popupMenu.foreground))
        .cornerRadius(NeevaUIConstants.menuCornerDefault)
    }
}

struct TrackingBlockedView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingBlockedView(trackerCount: 100, domainCount: 100, siteName: "Google.com")
    }
}
