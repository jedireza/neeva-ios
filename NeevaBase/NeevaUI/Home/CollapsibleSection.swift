//
//  CollapsibleSection.swift
//  Client
//
//  Created by Bertoldo on 01/04/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

struct Collapsible<Content: View>: View {

    @State var title: String
    @State var content: () -> Content

    @State private var collapsed: Bool = false

    var body: some View {
        VStack {
            HStack(alignment: .center){
                Text(self.title)
                    .font(.homeSectionTitleFont)
                    .fontWeight(.regular)
                    .foregroundColor(.homeSectionTitleColor)
                    .lineLimit(1)
                Spacer()
                Button(action: {
                    print("Collapsible current state: \(collapsed)")
                    self.collapsed.toggle()
                } ) {
                    Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                        .accessibilityLabel("collapse_button")
                        .frame(width: 32, height: 32, alignment: .center)
                        .foregroundColor(Color.blue)
                        .background(Color.homeSectionCollapseButtonBackgroundColor)
                        .clipShape(Circle())
                }
            }
            .padding(EdgeInsets(top: 9, leading: 16, bottom: 0, trailing: 8)).background(Color.clear)

            VStack {
                self.content()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : nil)
            .clipped()
        }
    }
}

struct CollapsibleSection_Previews: PreviewProvider {
    static var previews: some View {
        Collapsible(title: "Collapsible Section Title") {
            VStack {
                Text("Neeva Home Text Content")
                Text("when Testing Collapsible")
                Text("Section")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.clear)
        }
        .frame(maxWidth: .infinity)
    }
}
