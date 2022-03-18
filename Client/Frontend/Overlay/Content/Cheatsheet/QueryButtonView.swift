//
//  QueryButtonView.swift
//  Client
//
//  Created by Edward Luo on 2022-03-18.
//  Copyright © 2022 Neeva. All rights reserved.
//

import Shared
import SwiftUI

struct QueryButtonView: View {
    @Environment(\.onOpenURL) var onOpenURL

    let query: String

    var body: some View {
        Button(action: onClick) {
            ScrollView(.horizontal) {
                HStack(alignment: .center) {
                    Label {
                        Text(query)
                            .foregroundColor(.label)
                    } icon: {
                        Symbol(decorative: .magnifyingglass)
                            .foregroundColor(.tertiaryLabel)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .withFont(unkerned: .bodyLarge)
        .lineLimit(1)
    }

    func onClick() {
        if let encodedQuery = query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed), !encodedQuery.isEmpty
        {
            ClientLogger.shared.logCounter(
                .RelatedSearchClick, attributes: EnvironmentHelper.shared.getAttributes())
            let target = URL(string: "\(NeevaConstants.appSearchURL)?q=\(encodedQuery)")!
            onOpenURL(target)
        }
    }
}
