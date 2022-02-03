// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

public enum OpenSysSettingTrigger: String {
    case defaultBrowserPrompt
    case defaultBrowserPromoCard
    case settings
}

class DefaultBrowserOnboardingViewController: UIHostingController<
    DefaultBrowserOnboardingViewController.Content
>
{
    struct Content: View {
        let openSettings: () -> Void
        let onCancel: () -> Void
        let triggerFrom: OpenSysSettingTrigger

        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    CloseButton(action: onCancel)
                        .padding(.trailing, 20)
                        .padding(.top)
                        .background(Color.clear)
                }
                DefaultBrowserOnboardingView(openSettings: openSettings, triggerFrom: triggerFrom)
            }
        }
    }

    init(didOpenSettings: @escaping () -> Void, triggerFrom: OpenSysSettingTrigger) {
        super.init(rootView: Content(openSettings: {}, onCancel: {}, triggerFrom: triggerFrom))
        self.rootView = Content(
            openSettings: { [weak self] in
                self?.dismiss(animated: true) {
                    UIApplication.shared.open(
                        URL(string: UIApplication.openSettingsURLString)!, options: [:])
                    didOpenSettings()
                }
                // Don't show default browser card if this button is tapped
                Defaults[.didDismissDefaultBrowserCard] = true
            },
            onCancel: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            },
            triggerFrom: triggerFrom
        )
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct DefaultBrowserOnboardingView: View {
    let openSettings: () -> Void
    let triggerFrom: OpenSysSettingTrigger

    var body: some View {
        VStack {
            Spacer()

            Text(String.DefaultBrowserCardTitle)
                .withFont(.displayMedium)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            Text(
                [
                    String.DefaultBrowserCardDescription,
                    String.DefaultBrowserOnboardingDescriptionStep1,
                    String.DefaultBrowserOnboardingDescriptionStep2,
                    String.DefaultBrowserOnboardingDescriptionStep3,
                ].joined(separator: "\n\n")
            )
            .withFont(.bodyXLarge)

            Spacer().repeated(3)

            ZStack {
                Image("Default Browser Setting Screenshot")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 350, height: 200)
                    .clipped()  // otherwise the image background blocks the close button
                    .overlay(
                        Text(String.DefaultBrowserOnboardingScreenshot)
                            .font(.system(size: 18))
                            .offset(x: 20, y: 122),
                        alignment: .topLeading
                    )
            }.accessibilityHidden(true)

            Spacer().repeated(3)

            Button(action: {
                ClientLogger.shared.logCounter(
                    .GoToSysAppSettings,
                    attributes: EnvironmentHelper.shared.getAttributes() + [
                        ClientLogCounterAttribute(
                            key: LogConfig.UIInteractionAttribute.openSysSettingSourceView,
                            value: String(describing: DefaultBrowserOnboardingView.self)
                        ),
                        ClientLogCounterAttribute(
                            key: LogConfig.UIInteractionAttribute.openSysSettingTriggerFrom,
                            value: triggerFrom.rawValue
                        ),
                    ]
                )
                openSettings()
            }) {
                HStack {
                    Spacer()
                    Text("Go to Settings")
                        .withFont(.labelLarge)
                    Spacer()
                }
            }
            .buttonStyle(.neeva(.primary))
            .font(.title3)
        }
        .padding(25)
        .navigationTitle("Default Browser")
    }
}

struct DefaultBrowserOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DefaultBrowserOnboardingView(openSettings: {}, triggerFrom: .defaultBrowserPrompt)
                .navigationBarTitleDisplayMode(.inline)
        }

        DefaultBrowserOnboardingViewController.Content(openSettings: {}, onCancel: {}, triggerFrom: .defaultBrowserPrompt)
    }
}
