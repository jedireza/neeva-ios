//
//  SwiftUIView.swift
//  
//
//  Created by Jed Fox on 12/18/20.
//

import SwiftUI

public struct SpaceView: View {
    let space: Space
    public init(_ space: Space) {
        self.space = space
    }
    public var body: some View {
        HStack(spacing: 15) {
            LargeSpaceIconView(space: space)
            VStack(alignment: .leading, spacing: 10) {
                Text(space.space?.name ?? "")
                    .font(.headline)
                HStack(spacing: 0) {
                    let count = space.space?.resultCount ?? 0
                    Text("\(count) item\(count == 1 ? "" : "s")")
                    Text("·").accessibility(hidden: true).padding(.horizontal, 4)
                    if let formattedDate = format(space.space?.lastModifiedTs, as: .full) {
                        Text(formattedDate)
                    }
                }.foregroundColor(.secondary)
            }
        }.padding(.vertical)
    }
}

struct SpaceView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SpaceView(TestSpaces.savedForLater)
            SpaceView(TestSpaces.stackOverflow)
        }
    }
}
