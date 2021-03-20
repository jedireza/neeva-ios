//
//  TrackingMenuView.swift
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

public struct TrackingMenuView: View {
    var menuAction: ((TrackingMenuButtonActions) -> ())?
    
    /// - Parameters:
    ///   - menuAction: menu button callback to trigger button action in UIKit
    public init(menuAction: ((TrackingMenuButtonActions) -> ())? = nil) {
        self.menuAction = menuAction
    }
    
    public var body: some View {
        VStack(alignment: .leading){
            //Scrollview added to handle smaller screens in landscape mode
            ScrollView{
                Group{
                    TrackingBlockedView(trackerCount: 127, domainCount: 34, siteName: "Neeva.co")
                }
                Group{
                    TrackingMenuProtectionRowButton(name:"Tracking Protection")
                    NeevaMenuRowButtonView(name:"Turn on Incognito", image:"menu-incognito")
                        .onTapGesture(perform: {self.menuAction!(TrackingMenuButtonActions.incognito)})
                    .frame(minWidth: 0, maxWidth: 310)
                }
                .padding(NeevaUIConstants.menuInnerPadding)
                .background(Color(UIColor.theme.popupMenu.foreground))
                .cornerRadius(NeevaUIConstants.menuCornerDefault)
            }
            .frame(minHeight: 0, maxHeight: 310)
        }
        .padding(NeevaUIConstants.menuOuterPadding)
        .background(Color(UIColor.theme.popupMenu.background))
    }
}

struct TrackingMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuView()
    }
}
