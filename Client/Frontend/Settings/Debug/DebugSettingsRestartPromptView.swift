// Copyright Neeva. All rights reserved.

import SwiftUI

struct DebugSettingsRestartPromptView: View {
    let isVisible: Bool
    var body: some View {
        if isVisible {
            HStack {
                Spacer()
                Text("Quit Neeva from the App Switcher and relaunch for feature flag changes to take effect")
                    .withFont(.labelLarge)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.white)
                Spacer()
            }.background(
                Color.orange
                    .overlay(Color.tertiarySystemFill)
                    .ignoresSafeArea()
            )
        }
    }
}

struct DebugSettingsRestartPromptView_Previews: PreviewProvider {
    static var previews: some View {
        DebugSettingsRestartPromptView(isVisible: true)
            .previewLayout(.sizeThatFits)
        DebugSettingsRestartPromptView(isVisible: true)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
