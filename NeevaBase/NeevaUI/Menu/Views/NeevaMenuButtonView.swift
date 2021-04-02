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
    let image: String
    let isDisabled: Bool
    let isSymbol: Bool
    
    /// - Parameters:
    ///   - name: The display name of the button
    ///   - image: Can be string id of the button image or symbol name
    ///   - isDisabled: Whether to apply gray out disabled style
    ///   - isSymbol: Wether image is a symbol name
    public init(name: String, image: String, isDisabled: Bool = false, isSymbol: Bool = true){
        self.buttonName = name
        self.image = image
        self.isDisabled = isDisabled
        self.isSymbol = isSymbol
    }
    
    public var body: some View {
        let buttonImage = self.isSymbol ?
            Image(systemName: self.image) : Image(self.image)

        Group{
            VStack{
                buttonImage
                    .renderingMode(.template)
                    .font(.system(size:20, weight:.regular))
                    .padding(.bottom,1)
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
