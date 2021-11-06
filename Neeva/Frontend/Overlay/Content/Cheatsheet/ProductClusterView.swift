// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct ProductClusterItem: View {
    let product: Product

    var body: some View {
        VStack(alignment: .center) {
            WebImage(url: URL(string: product.thumbnailURL))
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 80, alignment: .center)
                .clipped()
            Text(product.productName)
                .font(.system(size: 8))
                .frame(width: 100, height: 20)
                .lineLimit(2)
            if let priceLow = product.priceLow {
                Text("$\(priceLow, specifier: "%.2f")")
                    .font(.system(size: 10))
                    .bold()
                    .foregroundColor(Color.brand.charcoal)
                    .padding(.top, 2)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .background(Color.brand.white)
        .cornerRadius(15)
        .shadow(color: .gray, radius: 2, x: 1, y: 2)
    }
}

struct ProductClusterList: View {
    let products: [Product]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Related Top Reviewed Products").withFont(.headingMedium)
                .padding(.leading, 12)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(products, id: \.thumbnailURL) { product in
                        ProductClusterItem(product: product)
                    }
                }
                .padding([.leading, .bottom], 12)
            }
        }
    }
}
