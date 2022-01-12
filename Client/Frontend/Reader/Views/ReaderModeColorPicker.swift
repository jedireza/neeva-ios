// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
