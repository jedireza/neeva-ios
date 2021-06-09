// Copyright Neeva. All rights reserved.

import SwiftUI

struct TabLocationView: View {
    var body: some View {
        Capsule()
            .fill(Color.systemFill)
            .overlay(HStack {

            })
            .frame(height: 42)
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabLocationView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
