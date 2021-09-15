// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct NotificationPromptViewOverlayContent: View {
    var body: some View {
        NotificationPromptView()
            .overlayIsFixedHeight(isFixedHeight: true)
            .background(Color(.systemBackground))
    }
}

struct NotificationPromptView: View {
    @Environment(\.hideOverlay) private var hideOverlay

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Stay in the know").withFont(.headingXLarge).padding(.top, 32)
                Text("From news to shopping, we bring the best of the web to you!")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
                Text("You can opt out in settings anytime.")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
            }
            .padding(.horizontal, 32)
            .fixedSize(horizontal: false, vertical: true)
            Image("notification-prompt", bundle: .main)
                .resizable()
                .frame(width: 259, height: 222)
                .padding(32)
            Button(
                action: {
                    NotificationPermissionHelper.shared.requestPermissionIfNeeded(
                        completion: {
                            hideOverlay()
                        }, openSettingsIfNeeded: false)
                    ClientLogger.shared.logCounter(.NotificationPromptEnable)
                },
                label: {
                    Text("Enable notifications")
                        .withFont(.labelLarge)
                        .foregroundColor(.brand.white)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(NeevaButtonStyle(.primary))
            .padding(.top, 36)
            .padding(.horizontal, 16)
            Button(
                action: {
                    hideOverlay()
                    ClientLogger.shared.logCounter(.NotificationPromptSkip)
                },
                label: {
                    Text("Skip for now")
                        .withFont(.labelLarge)
                        .foregroundColor(.ui.adaptive.blue)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                }
            ).padding(.top, 10)
        }
        .padding(.bottom, 20)
    }
}

struct NotificationPromptView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPromptView()
    }
}
