import SwiftUI

extension String {
    var dataURIBody: Data? {
        guard starts(with: "data:") else { return nil }
        guard let payloadStart = range(of: ",")?.upperBound else { return nil }
        let payload = String(self[payloadStart..<self.endIndex])
        if range(of: "base64,")?.upperBound == payloadStart {
            return Data(base64Encoded: payload)
        } else {
            // TODO: implement support for none-base64 data URIs if needed
            return nil
        }
    }
}

fileprivate struct Metrics {
    static let size: CGFloat = 70
    static let cornerRadius: CGFloat = 8
    static let starSize: CGFloat = 35
    static let textSize: CGFloat = 26.25
}

struct LargeSpaceIconView: View {
    let space: SpaceListController.Space

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

    var body: some View {
        if space.space!.isDefaultSpace ?? false {
            EmptyIcon(background: space.space!.resultCount ?? 0 == 0 ? .spaceIconBackground : .gray96) {
                Image(systemName: "star.fill")
                    .font(.system(size: Metrics.starSize))
                    .foregroundColor(.savedForLaterIcon)
            }
        } else if
            let thumbnail = space.space!.thumbnail?.dataURIBody,
            let image = UIImage(data: thumbnail) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Metrics.size, height: Metrics.size, alignment: .center)
                .cornerRadius(Metrics.cornerRadius)
        } else {
            EmptyIcon(background: .spaceIconBackground) {
                if let name = space.space!.name {
                    Text(firstCharacters(2, from: name))
                        .foregroundColor(.white)
                        .font(.system(size: Metrics.textSize, weight: .medium, design: .default))
                }
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
