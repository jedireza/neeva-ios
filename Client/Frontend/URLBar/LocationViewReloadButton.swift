// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct LocationViewReloadButton: View {
    @Binding var state: ReloadButtonState
    var body: some View {
        if state != .disabled {
            TabLocationBarButton(label: state == .reload ? Symbol(.arrowClockwise) : Symbol(.xmark)) {}
        }
    }
}

struct LocationViewReloadButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LocationViewReloadButton(state: .constant(.disabled))
            LocationViewReloadButton(state: .constant(.reload))
            LocationViewReloadButton(state: .constant(.stop))
        }
    }
}
