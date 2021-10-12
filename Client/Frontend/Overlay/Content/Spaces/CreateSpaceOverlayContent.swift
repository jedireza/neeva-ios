// Copyright Neeva. All rights reserved.

import Combine
import Shared
import SwiftUI

struct CreateSpaceOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay
    @EnvironmentObject var spaceModel: SpaceCardModel
    @State private var subscription: AnyCancellable? = nil

    var body: some View {
        CreateSpaceView { spaceName in
            if !spaceName.isEmpty {
                let request = CreateSpaceRequest(name: spaceName)
                subscription = request.$state.sink { state in
                    switch state {
                    case .success:
                        SpaceStore.shared.refresh()
                        subscription = SpaceStore.shared.$state.sink { state in
                            if case .ready = state, spaceModel.allDetails.first?.title == spaceName
                            {
                                DispatchQueue.main.async {
                                    spaceModel.allDetails.first?.isShowingDetails = true
                                    subscription?.cancel()
                                }

                            }
                        }
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
