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
    
    /// - Parameters:
    ///   - name: The display name of the button
    ///   - image: The string id of the button image
    public init(name: String, image: String){
        self.buttonName = name
        self.buttonImage = image
    }
    
    public var body: some View {
        Group{
            VStack{
                Image(buttonImage)
                Text(buttonName)
                    .foregroundColor(Color.menuText)
                    .font(.system(size: NeevaUIConstants.menuButtonFontSize))
            }
        }
        .padding(NeevaUIConstants.menuInnerPadding)
        .frame(minWidth: 0, maxWidth: 75)
        .background(Color.menuPrimary)
        .cornerRadius(NeevaUIConstants.menuCornerDefault)
    }
}

struct NeevaMenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuButtonView(name: "Test", image: "iphone")
    }
}
