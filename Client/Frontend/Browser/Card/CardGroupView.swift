// Copyright Neeva. All rights reserved.

import SwiftUI

// MARK: ThumbnailGroup

fileprivate struct ThumbnailItem<Content: View>: View {
    let content: Content
    let action: () -> ()

    var body: some View {
        Button(action: action) {
            content
                .cornerRadius(CardUX.CornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: CardUX.CornerRadius)
                        .stroke(Color.tertiaryLabel)
                )
        }
    }
}

struct ThumbnailGroupView<Model: ThumbnailModel>: View {
    @ObservedObject var model: Model
    @Environment(\.selectionCompletion) var selectionCompletion: () -> ()

    private let spacing: CGFloat = 12
    private let smallSpacing: CGFloat = 4

    var body: some View {
        GeometryReader { geom in
            let size = (geom.size.width - spacing) / 2
            if size < 0 {
                (print(geom.size), Group {}).1
            }
            LazyVGrid(columns: .init(repeating: GridItem(.fixed(size), spacing: spacing, alignment: .topLeading), count: 2)) {
                ForEach(model.allDetails.prefix(3)) { item in
                    ThumbnailItem(content: item.thumbnail.frame(width: size, height: size)) {
                        item.onSelect()
                        selectionCompletion()
                    }
                }
//                if model.allDetails.count == 4, let last = model.allDetails.last {
//                    ThumbnailItem(content: last.thumbnail) {
//                        last.onSelect()
//                        selectionCompletion()
//                    }
//                } else if model.allDetails.count > 4 {
//                    // TODO
//                }
            }
        }.padding(10)
    }
}

// MARK: ColorThumbnail for Preview

fileprivate class PreviewThumbnailModel: ThumbnailModel {
    fileprivate struct ColorThumbnail: SelectableThumbnail {
        let id = UUID()
        let color: Color
        var thumbnail: Color { color }

        func onSelect() {}
    }

    let color: Color
    var num: Int

    init(color: Color, num: Int) {
        self.color = color
        self.num = num
    }

    var allDetails: [ColorThumbnail] {
        set(newDetails) {
            num = newDetails.count
        }

        get {
            Array(repeating: ColorThumbnail(color: color), count: num)
        }
    }
}

struct CardGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(0..<3) { count in
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .purple, num: count))
                .previewDisplayName("\(count)")
                .aspectRatio(1, contentMode: .fit)
                .previewLayout(
                    .fixed(width: CardUX.DefaultCardSize, height: CardUX.DefaultCardSize)
                )
        }
    }
}
