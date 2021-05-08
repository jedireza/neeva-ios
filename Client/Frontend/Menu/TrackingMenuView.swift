//
//  TrackingMenuView.swift
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

public struct TrackingMenuView: View {
    var menuAction: ((TrackingMenuButtonActions) -> ())?
    var isTrackingProtectionEnabled: Bool

    /// - Parameters:
    ///     - menuAction: menu button callback to trigger button action in UIKit
    ///     - isTrackingProtectionEnabled: Passed through preference value for tracking protection settings for the app
    public init(menuAction: ((TrackingMenuButtonActions) -> ())? = nil, isTrackingProtectionEnabled: Bool) {
        self.menuAction = menuAction
        self.isTrackingProtectionEnabled = isTrackingProtectionEnabled
    }
    
    public var body: some View {
        VStack(alignment: .leading){
            //Scrollview added to handle smaller screens in landscape mode
            ScrollView{
                //Removing tracking until data is available to display
                //Tracking and Incognito for Shield Menu https://github.com/neevaco/neeva-ios-phoenix/issues/106
                /*Group{
                    TrackingBlockedView(trackerCount: 127, domainCount: 34, siteName: "Neeva.co")
                }*/
                Group{
                    TrackingMenuProtectionRowButton(name:"Block Tracking",
                                                    toggleAction: toggleTrackingProtection,
                                                    isTrackingProtectionOn: isTrackingProtectionEnabled)
                }
                .padding(NeevaUIConstants.menuInnerPadding)
                .background(Color(UIColor.theme.popupMenu.foreground))
                .cornerRadius(NeevaUIConstants.menuCornerDefault)
            }
            .frame(minHeight: 0, maxHeight: NeevaUIConstants.trackingMenuMaxHeight)
        }
        .padding(NeevaUIConstants.menuOuterPadding)
        .background(Color(UIColor.theme.popupMenu.background))
    }

    func toggleTrackingProtection(){
        self.menuAction!(TrackingMenuButtonActions.tracking)
    }
}

struct TrackingMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuView(isTrackingProtectionEnabled: true)
    }
}
