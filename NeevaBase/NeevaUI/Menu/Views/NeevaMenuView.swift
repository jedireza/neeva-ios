//
//  NeevaMenuView.swift
//
//
//  Created by Stuart Allen on 3/13/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

public struct NeevaMenuView: View {
    var menuAction: ((NeevaMenuButtonActions) -> ())?
    
    /// - Parameters:
    ///   - menuAction: menu button callback to trigger button action in UIKit
    public init(menuAction: ((NeevaMenuButtonActions) -> ())? = nil) {
        self.menuAction = menuAction
    }
    
    public var body: some View {
        VStack(alignment: .leading){
            //Scrollview added to handle smaller screens in landscape mode
            ScrollView{
                Group{
                    HStack(spacing: NeevaUIConstants.menuHorizontalSpacing){
                        NeevaMenuButtonView(name:"Home", image:"menu-home-alt")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.home)})
                        NeevaMenuButtonView(name:"Spaces", image:"menu-spaces")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.spaces)})
                        NeevaMenuButtonView(name:"Settings", image:"menu-settings")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.settings)})
                        NeevaMenuButtonView(name:"History", image:"menu-history")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.history)})
                    }
                    .background(Color.transparent)
                    .cornerRadius(NeevaUIConstants.menuCornerDefault)
                }
                Group{
                    NeevaMenuRowButtonView(name:"Downloads", image:"menu-downloads")
                        .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.downloads)})
                    VStack{
                        NeevaMenuRowButtonView(name:"Send Feedback", image:"menu-feedback")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.feedback)})
                        Divider()
                        NeevaMenuRowButtonView(name:"Privacy Policy", image:"menu-privacy")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.privacyPolicy)})
                        Divider()
                        NeevaMenuRowButtonView(name:"Help Center", image:"menu-help")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.helpCenter)})
                    }
                    .frame(minWidth: 0, maxWidth: NeevaUIConstants.menuMaxWidth)
                    NeevaMenuRowButtonView(name:"Sign out", image:"menu-signout")
                        .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.signOut)})
                }
                .padding(NeevaUIConstants.menuInnerPadding)
                .background(Color(UIColor.theme.popupMenu.foreground))
                .cornerRadius(NeevaUIConstants.menuCornerDefault)
            }
            .frame(minHeight: 0, maxHeight: NeevaUIConstants.menuMaxHeight)
        }
        .padding(NeevaUIConstants.menuOuterPadding)
        .background(Color(UIColor.theme.popupMenu.background))
    }
}

struct NeevaMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuView()
     }
}

