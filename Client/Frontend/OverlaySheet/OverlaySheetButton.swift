// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct OverlaySheetButton<Label: View>: View {
    var action: () -> ()
    var label: () -> Label

    private let cellHeight: CGFloat = 52

    var body: some View {
        OverlayGroupCell {
            Button(action: action) {
                HStack {
                    Spacer()
                    label()
                    Spacer()
                }.frame(height: cellHeight)
            }
        }.buttonStyle(TableCellButtonStyle())
    }
}

extension OverlaySheetButton where Label == Text {
    init<S: StringProtocol>(_ label: S, action: @escaping () -> ()) {
        self.label = { Text(label) }
        self.action = action
    }
}

struct OverlaySheetButton_Previews: PreviewProvider {
    static var previews: some View {
        OverlaySheetButton(action: {}) {
            Text("Test")
        }
    }
}
