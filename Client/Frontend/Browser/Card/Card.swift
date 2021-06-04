//  Copyright © 2021 Neeva. All rights reserved.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct CardSpec: ViewModifier {
    let size: CGFloat

    func body(content: Content) -> some View {
        content.frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8)).shadow(radius: 4)
    }
}

private extension View {
    func applyCardSpec(size: CGFloat) -> some View {
        self.modifier(CardSpec(size: size))
    }
}


struct Card<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            if let favicon = details.favicon {
                favicon.resizable()
                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
                    .scaledToFit()
                    .applyCardSpec(size: 32)

            } else {
                Rectangle().foregroundColor(.primary)
                    .applyCardSpec(size: 32)
            }
            if let thumbnail = details.thumbnail {
                Image(uiImage: thumbnail).resizable().aspectRatio(contentMode: .fill)
                    .applyCardSpec(size: 180)
            } else {
                Rectangle().foregroundColor(.primary)
                    .applyCardSpec(size: 180)
            }
            if let buttonImage = details.closeButtonImage {
                Button(action: {
                    details.onClose()
                }, label: {
                    Image(uiImage: buttonImage).resizable().renderingMode(.template)
                        .foregroundColor(.primary)
                        .scaledToFit().padding(4)
                        .applyCardSpec(size: 32)
                })
            }
        }.onTapGesture {
            details.onSelect()
        }
    }
}

