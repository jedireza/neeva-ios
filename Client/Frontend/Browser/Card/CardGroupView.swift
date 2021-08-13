// Copyright Neeva. All rights reserved.

import SwiftUI

// MARK: ThumbnailGroup

enum ThumbnailGroupViewUX {
    static let Spacing: CGFloat = 12
}

struct ThumbnailGroupView<Model: ThumbnailModel>: View {
    @ObservedObject var model: Model
    @Environment(\.cardSize) private var size

    var contentSize: CGFloat {
        size - 2 * ThumbnailGroupViewUX.Spacing
    }

    var numItems: Int {
        model.allDetails.count
    }

    var itemSize: CGFloat {
        (contentSize - ThumbnailGroupViewUX.Spacing) / 2
    }

    var columns: [GridItem] {
        Array(
            repeating: GridItem(
                .fixed(itemSize),
                spacing: ThumbnailGroupViewUX.Spacing,
                alignment: .top),
            count: 2)
    }

    func itemFor(_ index: Int) -> some View {
        let item = model.allDetails[index]
        return item.thumbnail.frame(width: itemSize, height: itemSize)
            .cornerRadius(CardUX.CornerRadius)
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: ThumbnailGroupViewUX.Spacing) {
            ForEach((0..<numItems).prefix(3), id: \.self) { index in
                itemFor(index)
            }
            if numItems == 4 {
                itemFor(3)
            } else if numItems > 4 {
                Text("+\(numItems - 3)")
                    .foregroundColor(Color.label)
                    .withFont(.labelLarge)
                    .frame(width: itemSize, height: itemSize)
                    .background(Color.systemFill)
                    .cornerRadius(CardUX.CornerRadius)
            }
        }.padding(ThumbnailGroupViewUX.Spacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.systemFill)
            .cornerRadius(CardUX.CornerRadius)
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
