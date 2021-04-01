//
//  NeevaMenuButtonView.swift
//  
//
//  Created by Stuart Allen on 13/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

public struct NeevaMenuButtonView: View {
    
    let buttonName: String
    let buttonImage: String
    let isDisabled: Bool
    
    /// - Parameters:
    ///   - name: The display name of the button
    ///   - image: The string id of the button image
    ///   - isDisabled: Whether to apply gray out disabled style
    public init(name: String, image: String, isDisabled: Bool = false){
        self.buttonName = name
        self.buttonImage = image
        self.isDisabled = isDisabled
    }
    
    public var body: some View {
        Group{
            VStack{
                Image(buttonImage)
                    .renderingMode(.template)
                    .foregroundColor(self.isDisabled ? Color(UIColor.theme.popupMenu.disabledButtonColor): Color(UIColor.theme.popupMenu.buttonColor))
                Text(buttonName)
                    .foregroundColor(self.isDisabled ? Color(UIColor.theme.popupMenu.disabledButtonColor): Color(UIColor.theme.popupMenu.textColor))
                    .font(.system(size: NeevaUIConstants.menuButtonFontSize))
            }
        }
        .padding(NeevaUIConstants.menuInnerPadding)
        .frame(minWidth: 0, maxWidth: NeevaUIConstants.menuButtonMaxWidth)
        .background(Color(UIColor.theme.popupMenu.foreground))
        .cornerRadius(NeevaUIConstants.menuCornerDefault)
        .disabled(self.isDisabled)
    }
}

struct NeevaMenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuButtonView(name: "Test", image: "iphone")
    }
}
