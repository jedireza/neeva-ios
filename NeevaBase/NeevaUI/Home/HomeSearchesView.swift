//
//  HomeSearchesView.swift
//  Client
//
//  Created by Bertoldo on 01/04/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

struct Search: Identifiable {
    var id = UUID()
    var keyWords: String
}

struct HomeSearchesView: View {

    private var title: String = "SEARCHS"

    @State var searches = [Search]()

    init(searches: [Search]) {
        self.searches = searches
    }

    var body: some View {
        Collapsible(title: title) {
            ForEach(searches) { search in
                HStack(spacing: 16) {
                    Text("\(Image(systemName: "clock"))")
                        .font(.searchesIconsFont)
                        .foregroundColor(.searchesIconsColor)
                    Text(search.keyWords)
                        .font(.searchesKeyWordsFont)
                        .fontWeight(.light)
                        .foregroundColor(.searchesKeyWordsColor)
                        .background(Color.clear)
                    Spacer()
                    Text("\(Image(systemName: "arrow.up.left"))")
                        .font(.searchesIconsFont)
                        .foregroundColor(.searchesIconsColor)
                }
                .contentShape(Rectangle())
//                .onTapGesture {
//                    print("Search[\(search.id)]: \(search.keyWords)")
//                }
            }
            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .frame(maxWidth: .infinity)
    }
}

struct HomeSearchesView_Previews: PreviewProvider {
    static var previews: some View {
        let searches = [
            Search(keyWords: "lebron james"),
            Search(keyWords: "neeva"),
            Search(keyWords: "knives out"),
            Search(keyWords: "nba")
        ]

        HomeSearchesView(searches: searches)
    }
}
