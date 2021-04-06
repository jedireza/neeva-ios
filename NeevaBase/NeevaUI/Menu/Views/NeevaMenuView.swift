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
    var isPrivate: Bool
    /// - Parameters:
    ///   - menuAction: menu button callback to trigger button action in UIKit
    ///   - isPrivate: true if current tab is in private mode, false otherwise
    public init(menuAction: ((NeevaMenuButtonActions) -> ())? = nil, isPrivate: Bool) {
        self.menuAction = menuAction
        self.isPrivate = isPrivate
    }
    
    public var body: some View {
        VStack(alignment: .leading){
            //Scrollview added to handle smaller screens in landscape mode
            ScrollView{
                Group{
                    HStack(spacing: NeevaUIConstants.menuHorizontalSpacing){
                        NeevaMenuButtonView(name:"Home", image: "menu-home-alt", isDisabled: self.isPrivate, isSymbol: false)
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.home)})
                            .disabled(self.isPrivate)
                        NeevaMenuButtonView(name:"Spaces", image: "bookmark", isDisabled: self.isPrivate)
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.spaces)})
                            .disabled(self.isPrivate)

                    }
                    .background(Color.transparent)
                    .cornerRadius(NeevaUIConstants.menuCornerDefault)
                }
                Group {
                    HStack(spacing: NeevaUIConstants.menuHorizontalSpacing){
                        NeevaMenuButtonView(name:"Downloads", image: "square.and.arrow.down")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.downloads)})
                        NeevaMenuButtonView(name:"History", image:"clock")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.history)})
                    }
                }
                .background(Color.transparent)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)
                Group{
                    VStack{
                        NeevaMenuRowButtonView(name:"Settings", image:"gear")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.settings)})
                        Divider()
                        NeevaMenuRowButtonView(name:"Send Feedback", image:"bubble.left")
                            .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.feedback)})
                    }
                    .frame(minWidth: 0, maxWidth: NeevaUIConstants.menuMaxWidth)
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
        NeevaMenuView(isPrivate: false)
     }
}

