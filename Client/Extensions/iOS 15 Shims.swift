// Copyright Neeva. All rights reserved.

import SwiftUI

extension View {
    @ViewBuilder
    func applySettingsListStyle() -> some View {
        if #available(iOS 15, *) {
            listStyle(InsetGroupedListStyle())
        } else {
            listStyle(GroupedListStyle())
        }
    }
}
