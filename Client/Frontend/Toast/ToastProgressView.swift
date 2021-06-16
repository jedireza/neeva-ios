// Copyright Neeva. All rights reserved.

import SwiftUI

struct ToastProgressView: View {
    @State var completed = false
    var backgroundColor: Color = Color(SimpleToastUX.ToastDefaultColor)

    var body: some View {
        ZStack(alignment: .center) {
            if completed {
                Circle()
                    .foregroundColor(.white)

                Image(systemName: "checkmark")
                    .foregroundColor(backgroundColor)
                    .padding(8)
            } else {
                Circle()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 2))
            }
        }.frame(width: 24, height: 24)
    }
}

struct ToastProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ToastProgressView()
            .preferredColorScheme(.dark)
    }
}
