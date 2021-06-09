// Copyright Neeva. All rights reserved.

import SwiftUI

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
