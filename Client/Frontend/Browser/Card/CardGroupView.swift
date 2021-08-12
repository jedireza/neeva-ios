// Copyright Neeva. All rights reserved.

import SwiftUI

// MARK: ThumbnailGroup

private struct ThumbnailGroupSpec: ViewModifier {
    let size: CGFloat
    let onSelect: () -> Void

    func body(content: Content) -> some View {
        Button(
            action: {
                onSelect()
            },
            label: {
                content.frame(width: size, height: size)
                    .cornerRadius(CardUX.CornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: CardUX.CornerRadius)
                            .stroke(Color.tertiaryLabel))
            })
    }
}

extension View {
    fileprivate func applyThumbnailGroupSpec(size: CGFloat, onSelect: @escaping () -> Void)
        -> some View
    {
        self.modifier(ThumbnailGroupSpec(size: size, onSelect: onSelect))
    }
}

struct ThumbnailGroupView<Model: ThumbnailModel>: View {
    @ObservedObject var model: Model
    @Environment(\.selectionCompletion) var selectionCompletion: () -> Void
    @Environment(\.cardSize) private var size

    let spacing: CGFloat = 12
    let smallSpacing: CGFloat = 4

    var contentSize: CGFloat {
        size - 10
    }

    var numItems: Int {
        model.allDetails.count
    }

    var itemSize: CGFloat {
        (contentSize - spacing) / 2
    }

    var smallItemSize: CGFloat {
        (itemSize - smallSpacing) / 2
    }

    var columns: [GridItem] {
        Array(
            repeating: GridItem(
                .fixed(itemSize),
                spacing: spacing,
                alignment: .top),
            count: 2)
    }

    var smallColumns: [GridItem] {
        Array(
            repeating: GridItem(
                .fixed(smallItemSize),
                spacing: smallSpacing),
            count: 2)
    }

    func itemFor(_ index: Int) -> some View {
        let item = model.allDetails[index]
        let blockSize = numItems < 5 ? itemSize : (index < 3 ? itemSize : smallItemSize)
        return item.thumbnail.applyThumbnailGroupSpec(
            size: blockSize,
            onSelect: index < 3
                ? {
                    item.onSelect()
                    selectionCompletion()
                } : {})
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: spacing) {
            ForEach((0..<numItems).prefix(3), id: \.self) { index in
                itemFor(index)
            }
            if numItems == 4 {
                itemFor(3)
            } else if numItems > 4 {
                LazyVGrid(
                    columns: smallColumns,
                    alignment: .center, spacing: 4
                ) {
                    ForEach((3..<numItems).prefix(4), id: \.self) { index in
                        itemFor(index)
                    }
                }
            }
        }.padding(10).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.white)
    }
}

// MARK: ColorThumbnail for Preview

private class PreviewThumbnailModel: ThumbnailModel {
    fileprivate struct ColorThumbnail: SelectableThumbnail {
        let color: Color
        var thumbnail: some View { color }

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
        VStack {
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .red, num: 1))
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .blue, num: 3))
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .black, num: 4))
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .green, num: 5))
            ThumbnailGroupView(model: PreviewThumbnailModel(color: .purple, num: 8))
        }
    }
}
