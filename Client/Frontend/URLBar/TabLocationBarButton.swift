// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct TabLocationBarButton<Label: View>: View {
    let label: Label
    let action: () -> ()

    var body: some View {
        Button(action: action) {
            label
                .frame(width: TabLocationViewUX.height, height: TabLocationViewUX.height)
        }.foregroundColor(.label)
    }
}

struct LocationViewReloadButton: View {
    @Binding var state: ReloadButtonState
    let onTap: () -> ()

    var body: some View {
        if state != .disabled {
            TabLocationBarButton(
                label: state == .reload ? Symbol(.arrowClockwise) : Symbol(.xmark),
                action: onTap
            )
        }
    }
}

struct TabLocationBarButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LocationViewReloadButton(state: .constant(.disabled)) {}
            LocationViewReloadButton(state: .constant(.reload)) {}
            LocationViewReloadButton(state: .constant(.stop)) {}
        }
    }
}

