// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

/// A `View` intended to be embedded within an `OverlayView`, used to
/// present the `AddToSpaceView` UI.
struct AddToSpaceOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    @ObservedObject var request: AddToSpaceRequest

    let bvc: BrowserViewController
    let importData: SpaceImportHandler?

    var body: some View {
        Group {
            if request.state == .savedToSpace || request.state == .savingToSpace {
                ShareAddedSpaceView(request: request, bvc: bvc)
            } else {
                AddToSpaceView(
                    request: request,
                    onDismiss: hideOverlay,
                    importData: importData
                )
            }
        }
        .overlayTitle(title: request.mode.title)
        .overlayIsFixedHeight(
            isFixedHeight: request.mode == .saveToNewSpace
                && (request.state == .creatingSpace || request.state == .initial)
        )
        .environment(\.onSigninOrJoinNeeva) {
            ClientLogger.shared.logCounter(
                .AddToSpaceErrorSigninOrJoinNeeva,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
            hideOverlay()
            bvc.presentIntroViewController(
                true,
                onDismiss: {
                    DispatchQueue.main.async {
                        bvc.hideCardGrid(withAnimation: true)
                    }
                }
            )
        }
    }
}
