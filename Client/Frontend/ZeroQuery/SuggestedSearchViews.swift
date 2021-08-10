// Copyright Neeva. All rights reserved.

import Shared
import Storage
import SwiftUI

struct SuggestedSearchesView: View {
    @EnvironmentObject var model: SuggestedSearchesModel

    @Environment(\.onOpenURL) private var openURL
    @Environment(\.setSearchInput) private var setSearchInput

    var body: some View {
        VStack(spacing: 0) {
            if model.suggestedQueries.isEmpty {
                ZeroQueryPlaceholder(label: "Your searches go here")
            }
            ForEach(model.suggestedQueries.prefix(3), id: \.1) { query, site in
                Button(action: { openURL(site.url) }) {
                    HStack {
                        Symbol(decorative: .clock)
                        Text(query.trimmingCharacters(in: .whitespacesAndNewlines))
                            .foregroundColor(.label)
                        Spacer()
                    }
                    .frame(height: 37)
                    .padding(.horizontal, ZeroQueryUX.Padding)
                }
                .onDrag { NSItemProvider(url: site.url) }
                .buttonStyle(TableCellButtonStyle())
                .overlay(
                    Button(action: { setSearchInput(query) }) {
                        VStack {
                            Spacer(minLength: 0)
                            Symbol(decorative: .arrowUpLeft)
                                .padding(.horizontal, 5)
                                .padding(.leading)
                            Spacer(minLength: 0)
                        }
                    }.padding(.trailing, ZeroQueryUX.Padding),
                    alignment: .trailing
                )
                .contextMenu { ZeroQueryCommonContextMenuActions(siteURL: site.url, title: nil, description: nil) }
            }
        }
        .accentColor(Color(light: .ui.gray70, dark: .secondaryLabel))
        .padding(.top, 7)
    }
}

struct SuggestedSearchesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ZeroQueryHeader(
                title: "Searches",
                action: {},
                label: "hide searches",
                icon: .chevronUp
            )
            SuggestedSearchesView()
                .environmentObject(
                    SuggestedSearchesModel(
                        suggestedQueries: [
                            ("lebron james", .init(url: "https://neeva.com", title: "", id: 1)),
                            ("neeva", .init(url: "https://neeva.com", title: "", id: 2)),
                            //                            ("knives out", .init(url: "https://neeva.com", title: "", id: 3)),
                            (
                                "    transition: all 0.25s;\n",
                                .init(url: "https://neeva.com", title: "", id: 4)
                            ),
                        ]
                    )
                )
        }
        .padding(.bottom)
        .previewLayout(.sizeThatFits)
    }
}
