// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct CreateSpaceOverlaySheetContent: View {
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    var body: some View {
        CreateSpaceView { spaceName in
            if !spaceName.isEmpty {
                let _ = CreateSpaceRequest(name: spaceName)
            }
            hideOverlaySheet()
        }
    }
}

struct CreateSpaceOverlaySheetContent_Previews: PreviewProvider {
    static var previews: some View {
        CreateSpaceOverlaySheetContent()
    }
}
