// Copyright Neeva. All rights reserved.

import SwiftUI

struct ReaderModeColorPicker: View {
    var theme: ReaderModeTheme
    var onSelect: (ReaderModeTheme) -> Void

    var body: some View {
        Button(action: { onSelect(theme) }) {
            Circle()
                .foregroundColor(theme.color)
                .overlay(
                    Circle().stroke(
                        Color(red: 152 / 255, green: 152 / 255, blue: 155 / 255), lineWidth: 0.5)
                )
                .frame(width: 26, height: 26)
        }
    }
}

struct ReaderModeColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReaderModeColorPicker(theme: .sepia, onSelect: { _ in })
        }
    }
}
