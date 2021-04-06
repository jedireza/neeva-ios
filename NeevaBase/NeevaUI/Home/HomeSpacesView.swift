//
//  HomeSpacesView.swift
//  Client
//
//  Created by Bertoldo on 01/04/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

struct Space: Identifiable {
    var id = UUID()
    var name: String
    var image: String
}

struct HomeSpacesView: View {

    private var title: String = "SPACES"

    @State var spaces = [Space]()

    init(spaces: [Space]) {
        self.spaces = spaces
    }

    var body: some View {
        Collapsible(title: title) {
            ForEach(self.spaces) { space in
                HStack() {
                    Image(space.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36.0, height: 36.0, alignment: .top)
                        .foregroundColor(.gray)
                        .cornerRadius(4)
                    Text(space.name)
                        .font(.spacesNameFont)
                        .fontWeight(.light)
                        .foregroundColor(.spacesNameColor)
                    Spacer()
                }
                .contentShape(Rectangle())
//                .onTapGesture {
//                    print("Spaces[\(space.id)]: \(space.name)")
//                }
            }
            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
    }
}

struct HomeSpacesView_Previews: PreviewProvider {
    static var previews: some View {
        let spaces = [
            Space(name: "Mountain Bike", image: "rectangle.grid.2x2"),
            Space(name: "SwiftUI", image: "rectangle.grid.2x2"),
            Space(name: "Travel", image: "rectangle.grid.2x2"),
            Space(name: "Cars", image: "rectangle.grid.2x2")
        ]

        HomeSpacesView(spaces: spaces)
    }
}
