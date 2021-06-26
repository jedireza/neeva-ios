// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Shared

enum CardUX {
    static let CardSize : CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 180 : 160
    static let ShadowRadius : CGFloat = 2
    static let CornerRadius : CGFloat = 8
    static let ButtonSize : CGFloat = 32
    static let FaviconSize : CGFloat = 20
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

enum CardConfig {
    case carousel
    case grid
}

struct Card<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    let config: CardConfig

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 0) {
                    if let favicon = details.favicon {
                        favicon.resizable()
                            .transition(.fade(duration: 0.5))
                            .scaledToFit().background(Color.white)
                            .applyCardSpec(size: CardUX.FaviconSize).padding(6)
                    }
                    if let title = details.title {
                        Text(title).font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.trailing, 6)
                    }
                    if case .grid = config, let buttonImage = details.closeButtonImage {
                        Button(action: {
                            details.onClose()
                        }, label: {
                            Image(uiImage: buttonImage).resizable().renderingMode(.template)
                                .foregroundColor(.label)
                                .scaledToFit()
                                .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                                .padding(6)
                        })
                    }
                }.frame(width: CardUX.CardSize, height: CardUX.ButtonSize)
                .background(Color(UIColor.Browser.background))
                .cornerRadius(CardUX.CornerRadius)
                .shadow(radius: CardUX.ShadowRadius)
            if let thumbnail = details.thumbnail {
                Button(action: details.onSelect,
                       label: {
                            thumbnail.applyCardSpec(size: CardUX.CardSize)
                       })
            } else {
                Rectangle().foregroundColor(.label)
                    .applyCardSpec(size: CardUX.CardSize)
            }
            if case .carousel = config {
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
            }
        }.onDrop(of: ["public.url", "public.text"], delegate: details)
    }
}

