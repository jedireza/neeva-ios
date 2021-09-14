// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

/// A `View` intended to be embedded within an `OverlayView`, used to
/// present the `AddToSpaceView` UI.
struct AddToSpaceOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    @ObservedObject var request: AddToSpaceRequest

    let importData: SpaceImportHandler?

    var body: some View {
        AddToSpaceView(
            request: request,
            onDismiss: hideOverlay,
            importData: importData
        )
        .overlayTitle(title: request.mode.title)
        .overlayIsFixedHeight(isFixedHeight: request.mode == .saveToNewSpace)
        .environment(\.logAuth) { isSignin in
            ClientLogger.shared.logCounter(
                isSignin
                    ? .AddToSpaceErrorLoginViewSignin
                    : .AddToSpaceErrorLoginViewSignUp,
                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
        }
    }
}
