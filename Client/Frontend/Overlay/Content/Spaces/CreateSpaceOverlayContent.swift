// Copyright Neeva. All rights reserved.

import Combine
import Shared
import SwiftUI

struct CreateSpaceOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay
    @EnvironmentObject private var gridModel: GridModel
    @State private var subscription: AnyCancellable? = nil

    var body: some View {
        CreateSpaceView { spaceName in
            if !spaceName.isEmpty {
                let request = CreateSpaceRequest(name: spaceName)
                subscription = request.$state.sink { state in
                    switch state {
                    case .success:
                        SpaceStore.shared.refresh()
                        gridModel.showSpaces()
                        subscription?.cancel()
                    case .failure:
                        subscription?.cancel()
                    case .initial:
                        Logger.browser.info("Waiting for result from creating space")
                    }
                }
            }
            
            hideOverlay()
        }.overlayIsFixedHeight(isFixedHeight: true)
    }
}

struct CreateSpaceOverlayContent_Previews: PreviewProvider {
    static var previews: some View {
        CreateSpaceOverlayContent()
    }
}
