// Copyright Neeva. All rights reserved.

import SwiftUI

struct PageProgressBarStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        GeometryReader { geom in
            Color.brand.adaptive.maya
                .frame(width: geom.size.width * CGFloat(progress))
        }
        .frame(height: 2)
    }
}

struct PageProgressBarStyle_Previews: PreviewProvider {
    static var previews: some View {
        let preview = VStack {
            ProgressView()
            ProgressView(value: 0)
            ProgressView(value: 0.25)
            ProgressView(value: 0.5).background(Color.red)
            ProgressView(value: 0.75)
            ProgressView(value: 1)
        }
        .padding()
        .progressViewStyle(PageProgressBarStyle())
        .previewLayout(.sizeThatFits)

        preview
        preview.preferredColorScheme(.dark)
    }
}
