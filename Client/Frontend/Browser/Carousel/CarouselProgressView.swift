// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared

class CarouselProgressModel: ObservableObject {
    @Published var urls: [URL]
    @Published var index: Int

    init(urls: [URL], index: Int) {
        self.urls = urls
        self.index = index
    }
}

fileprivate struct CarouselProgressUX {
    static let SelectedSize: CGFloat = 18
    static let RegularSize: CGFloat = 12
    static let Padding: CGFloat = 4
    static let MinHeight: CGFloat = {
        SelectedSize + 2 * Padding
    }()
}

struct CarouselProgressView: View {
    @ObservedObject var model: CarouselProgressModel

    var body: some View {
        HStack(alignment: .center) {
            ForEach(Array(model.urls.enumerated()), id: \.0) { i, url in
                let size: CGFloat = i == model.index ?
                    CarouselProgressUX.SelectedSize : CarouselProgressUX.RegularSize
                FaviconView(site: Site(url: url.absoluteString, title: ""),
                            size: size, bordered: false)
                    .frame(width: size, height: size).clipShape(Circle())
                    .shadow(radius: 2).animation(model.index == -1 ? nil : .spring())
            }
        }.padding(CarouselProgressUX.Padding)
        .frame(minHeight: CarouselProgressUX.MinHeight)
        .background(LinearGradient(
                        gradient: Gradient(colors:[Color.neeva.brand.pistachio,
                                                   Color.neeva.brand.blue,
                                                   Color.neeva.brand.pistachio]),
                        startPoint: .leading, endPoint: .trailing))
        .clipShape(Capsule()).shadow(radius: 3).padding()
    }
}

struct CarouselProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselProgressView(model: CarouselProgressModel(urls: [URL(string: "http://facebook.com")!, URL(string: "http://facebook.com")!, URL(string: "http://google.com")!, URL(string: "http://facebook.com")!, URL(string: "http://theverge.com")!, URL(string: "http://facebook.com")!, URL(string: "http://google.com")!, URL(string: "http://facebook.com")!, URL(string: "http://facebook.com")!, URL(string: "http://facebook.com")!, URL(string: "http://linkedin.com")!, URL(string: "http://facebook.com")!, URL(string: "http://google.com")!, URL(string: "http://facebook.com")!, URL(string: "http://hp.com")!], index: 0))
    }
}
