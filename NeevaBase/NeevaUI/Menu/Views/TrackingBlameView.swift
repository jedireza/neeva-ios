//
//  TrackingBlameView.swift
//  Client
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

public struct TrackingBlameView: View {
    
    let shameCount: Int
    let buttonImage: String
    
    /// - Parameters:
    ///   - name: The display name of the button
    ///   - image: The string id of the button image
    public init(shameCount: Int, image: String){
        self.shameCount = shameCount
        self.buttonImage = image
    }
    
    public var body: some View {
        Group{
            HStack{
                Image(buttonImage)
                    .renderingMode(.template)
                    .foregroundColor(Color(UIColor.theme.popupMenu.buttonColor))
                Text("\(shameCount)")
                    .foregroundColor(Color(UIColor.theme.popupMenu.textColor))
                    .font(.system(size: NeevaUIConstants.menuButtonFontSize))
            }
        }
    }
}

struct TrackingBlameView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingBlameView(shameCount: 10, image: "iphone")
    }
}
