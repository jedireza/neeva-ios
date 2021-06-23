// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Shared

enum CardUX {
    static let CardSize : CGFloat = 180
    static let ShadowRadius : CGFloat = 4
    static let CornerRadius : CGFloat = 8
    static let ButtonSize : CGFloat = 32
}

struct CardSpec: ViewModifier {
    let size: CGFloat

    func body(content: Content) -> some View {
        content.frame(width: size, height: size)
            .cornerRadius(CardUX.CornerRadius)
            .shadow(radius: CardUX.ShadowRadius)
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
                    .scaledToFit().background(Color.white)
                    .applyCardSpec(size: CardUX.ButtonSize)
            } else if let title = details.title {
                Text(title).font(.headline)
                    .frame(height: CardUX.ButtonSize)
                    .frame(maxWidth: CardUX.CardSize)
                    .background(Color(UIColor.Browser.background))
                    .cornerRadius(CardUX.CornerRadius)
                    .shadow(radius: CardUX.ShadowRadius)
            } else {
                Rectangle().foregroundColor(.clear)
                    .applyCardSpec(size: CardUX.ButtonSize)
            }
            if let thumbnail = details.thumbnail {
                thumbnail
                    .applyCardSpec(size: CardUX.CardSize)
            } else {
                Rectangle().foregroundColor(.label)
                    .applyCardSpec(size: CardUX.CardSize)
            }
            if let buttonImage = details.closeButtonImage {
                Button(action: {
                    details.onClose()
                }, label: {
                    Image(uiImage: buttonImage).resizable().renderingMode(.template)
                        .foregroundColor(.white)
                        .scaledToFit().padding(4)
                        .applyCardSpec(size: CardUX.ButtonSize)
                })
            } else {
                Rectangle().foregroundColor(.clear)
                    .applyCardSpec(size: CardUX.ButtonSize)
            }
        }.onTapGesture {
            details.onSelect()
        }.onDrop(of: ["public.url", "public.text"], delegate: details)
    }
}

