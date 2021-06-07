// Copyright © Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared

fileprivate struct ListRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background(
                Color(UIColor(light: .Custom.selectedHighlightLight, dark: .Custom.selectedHighlightDark))
                    .opacity(configuration.isPressed ? 1 : 0)
                    .padding(.horizontal, -16)
            )
    }
}

struct SuggestedSearchesView: View {
    @EnvironmentObject var model: SuggestedSearchesModel

    @Environment(\.onOpenURL) private var openURL
    @Environment(\.setSearchInput) private var setSearchInput

    var body: some View {
        VStack(spacing: 0) {
            ForEach(model.suggestedQueries.prefix(3), id: \.1) { query, site in
                Button(action: { openURL(URL(string: site.url)!) }) {
                    HStack {
                        Symbol(.clock)
                        Text(query.trimmingCharacters(in: .whitespacesAndNewlines))
                            .foregroundColor(.label)
                        Spacer()
                    }
                    .frame(height: 37)
                }
                .buttonStyle(ListRowButtonStyle())
                .overlay(
                    Button(action: { setSearchInput(query) }) {
                        VStack {
                            Spacer(minLength: 0)
                            Symbol(.arrowUpLeft)
                                .padding(.horizontal, 5)
                                .padding(.leading)
                            Spacer(minLength: 0)
                        }
                    },
                    alignment: .trailing
                )
            }
        }
        .foregroundColor(Color(light: .Neeva.UI.Gray70, dark: .secondaryLabel))
        .padding(.top, 7)
    }
}

struct SuggestedSearchesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            NeevaHomeHeader(
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
                            ("    transition: all 0.25s;\n", .init(url: "https://neeva.com", title: "", id: 4))
                        ]
                    )
                )
                .padding(.horizontal, NeevaHomeUX.HeaderPadding)
        }
        .padding(.bottom)
        .previewLayout(.sizeThatFits)
    }
}
