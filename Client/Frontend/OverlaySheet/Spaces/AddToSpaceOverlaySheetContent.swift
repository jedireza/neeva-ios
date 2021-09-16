// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

/// A `View` intended to be embedded within an `OverlaySheetView`, used to
/// present the `AddToSpaceView` UI.
struct AddToSpaceOverlaySheetContent: View {
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    @ObservedObject var request: AddToSpaceRequest

    let bvc: BrowserViewController
    let importData: SpaceImportHandler?

    var body: some View {
        AddToSpaceView(
            request: request,
            onDismiss: hideOverlaySheet,
            importData: importData
        )
        .overlaySheetTitle(title: request.mode.title)
        .overlaySheetIsFixedHeight(isFixedHeight: request.mode == .saveToNewSpace)
        .environment(\.onSigninOrJoinNeeva) {
            ClientLogger.shared.logCounter(
                .AddToSpaceErrorSigninOrJoinNeeva,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
            hideOverlaySheet()
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
