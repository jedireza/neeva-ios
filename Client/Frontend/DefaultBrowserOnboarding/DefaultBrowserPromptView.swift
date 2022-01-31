// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct DefaultBrowserPromptView: View {
    var skipAction: () -> Void
    var buttonAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Make Neeva your Default Browser").withFont(.headingXLarge).padding(.top, 32)
                Text(
                    "Load websites safely and quickly, with our mobile tracker blocking technology."
                )
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
                Text("You can change your default browser in Settings anytime.")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
            }
            .padding(.horizontal, 32)
            .fixedSize(horizontal: false, vertical: true)
            Image("default-browser-prompt", bundle: .main)
                .resizable()
                .frame(width: 300, height: 205)
                .padding(32)
            Button(
                action: {
                    buttonAction()
                    if NeevaUserInfo.shared.hasLoginCookie() {
                        ClientLogger.shared.logCounter(.DefaultBrowserPromptOpen)
                    } else {
                        Defaults[.lastDefaultBrowserPromptInteraction] =
                            LogConfig.Interaction.DefaultBrowserPromptOpen.rawValue
                    }
                },
                label: {
                    Text("Set as Default Browser")
                        .withFont(.labelLarge)
                        .foregroundColor(.brand.white)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(.neeva(.primary))
            .padding(.top, 36)
            .padding(.horizontal, 16)
            Button(
                action: {
                    skipAction()
                    if NeevaUserInfo.shared.hasLoginCookie() {
                        ClientLogger.shared.logCounter(.DefaultBrowserPromptSkip)
                    } else {
                        Defaults[.lastDefaultBrowserPromptInteraction] =
                            LogConfig.Interaction.DefaultBrowserPromptSkip.rawValue
                    }
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

class DefaultBrowserPromptViewController: UIHostingController<AnyView> {
    var skipAction: () -> Void
    var buttonAction: () -> Void

    init(skipAction: @escaping () -> Void, buttonAction: @escaping () -> Void) {
        self.skipAction = skipAction
        self.buttonAction = buttonAction

        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            DefaultBrowserPromptView(skipAction: skipAction, buttonAction: buttonAction)
        )
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct DefaultBrowserPromptView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultBrowserPromptView(
            skipAction: {
            },
            buttonAction: {
            }
        )
    }
}
