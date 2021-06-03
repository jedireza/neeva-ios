// Copyright © Neeva. All rights reserved.

import SwiftUI

extension Color {
    public init(light: Color, dark: Color) {
        self.init(UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
}
