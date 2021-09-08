// Copyright Neeva. All rights reserved.

import SwiftUI

// MARK: ThumbnailGroup

enum ThumbnailGroupViewUX {
    static let Spacing: CGFloat = 6
    static let ShadowRadius: CGFloat = 2
    static let ThumbnailCornerRadius: CGFloat = 7
    static let ThumbnailsContainerRadius: CGFloat = 16
}

struct RoundedCorners: Shape {
    var corners: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(corners[1], h / 2), w / 2)
        let tl = min(min(corners[0], h / 2), w / 2)
        let bl = min(min(corners[2], h / 2), w / 2)
        let br = min(min(corners[3], h / 2), w / 2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(
            center: CGPoint(x: w - tr, y: tr), radius: tr,
            startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(
            center: CGPoint(x: w - br, y: h - br), radius: br,
            startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(
            center: CGPoint(x: bl, y: h - bl), radius: bl,
            startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(
            center: CGPoint(x: tl, y: tl), radius: tl,
            startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}

private struct CustomRadius: ViewModifier {
    let index: Int

    var corners: [CGFloat] {
        var temp: [CGFloat] = Array.init(
            repeating: ThumbnailGroupViewUX.ThumbnailCornerRadius, count: 4)
        temp[index] = ThumbnailGroupViewUX.ThumbnailsContainerRadius
        return temp
    }

    func body(content: Content) -> some View {
        content.clipShape(RoundedCorners(corners: corners))
    }
}

struct ThumbnailGroupView<Model: ThumbnailModel>: View {
    @ObservedObject var model: Model
    @Environment(\.cardSize) private var size

    var numItems: Int {
        model.allDetails.count
    }

    var contentSize: CGFloat {
        size
    }

    var itemSize: CGFloat {
        (contentSize - ThumbnailGroupViewUX.Spacing) / 2 - ThumbnailGroupViewUX.ShadowRadius
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
        Group {
            if index >= numItems {
                Color.DefaultBackground.frame(width: itemSize, height: itemSize)
                    .modifier(CustomRadius(index: index))
            } else {
                let item = model.allDetails[index]
                item.thumbnail.frame(width: itemSize, height: itemSize)
                    .modifier(CustomRadius(index: index))
            }
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: ThumbnailGroupViewUX.Spacing) {
            ForEach(0...2, id: \.self) { index in
                itemFor(index)
            }
            if numItems <= 4 {
                itemFor(3)
            } else if numItems > 4 {
                Text("+\(numItems - 3)")
                    .foregroundColor(Color.secondaryLabel)
                    .withFont(.labelLarge)
                    .frame(width: itemSize, height: itemSize)
                    .background(Color.DefaultBackground)
                    .modifier(CustomRadius(index: 3))
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.clear)
            .drawingGroup()
            .shadow(color: Color.black.opacity(0.25), radius: 1)
            .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
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
