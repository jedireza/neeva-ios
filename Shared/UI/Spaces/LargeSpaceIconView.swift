// Copyright Neeva. All rights reserved.

import SwiftUI

fileprivate struct Metrics {
    static let size: CGFloat = 36
    static let cornerRadius: CGFloat = 4
    static let starSize: CGFloat = 24
    static let textSize: CGFloat = 16
}

/// Displayed in space lists
public struct LargeSpaceIconView: View {
    let space: Space

    public init(space: Space) {
        self.space = space
    }

    struct EmptyIcon<Content: View>: View {
        let background: Color
        let content: () -> Content
        init(background: Color,  @ViewBuilder _ content: @escaping () -> Content) {
            self.background = background
            self.content = content
        }
        var body: some View {
            RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                .fill(background)
                .overlay(content())
                .frame(width: Metrics.size, height: Metrics.size)
        }
    }

    public var body: some View {
        if space.isDefaultSpace {
            EmptyIcon(background: space.resultCount == 0 ? .spaceIconBackground : .neeva.ui.fixed.gray96) {
                Image(systemSymbol: .starFill)
                    .frame(height: 24)
                    .foregroundColor(.savedForLaterIcon)
            }
        } else if
            let thumbnail = space.thumbnail?.dataURIBody,
            let image = UIImage(data: thumbnail) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Metrics.size, height: Metrics.size, alignment: .center)
                .cornerRadius(Metrics.cornerRadius)
        } else {
            EmptyIcon(background: .spaceIconBackground) {
                Text(firstCharacters(2, from: space.name))
                    .foregroundColor(.white)
                    .font(.system(size: Metrics.textSize, weight: .semibold, design: .default))
                    .accessibilityHidden(true)
            }
        }
    }
}

struct LargeSpaceIconView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LargeSpaceIconView(space: .empty)
            LargeSpaceIconView(space: .stackOverflow)
            LargeSpaceIconView(space: .savedForLater)
            LargeSpaceIconView(space: .savedForLaterEmpty)
        }.padding().previewLayout(.sizeThatFits)
    }
}
