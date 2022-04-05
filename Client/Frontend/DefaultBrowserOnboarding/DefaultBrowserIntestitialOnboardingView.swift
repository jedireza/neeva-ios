// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

class DefaultBrowserInterstitialOnboardingViewController: UIHostingController<
    DefaultBrowserInterstitialOnboardingViewController.Content
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
                DefaultBrowserInterstitialOnboardingView(
                    trigger: .promoCard,
                    showSkipButton: false,
                    skipAction: {},
                    buttonAction: {
                        openSettings()
                    }
                )
            }
        }
    }

    init(didOpenSettings: @escaping () -> Void, triggerFrom: OpenSysSettingTrigger) {
        super.init(rootView: Content(openSettings: {}, onCancel: {}, triggerFrom: triggerFrom))
        self.rootView = Content(
            openSettings: { [weak self] in
                self?.dismiss(animated: true) {
                    UIApplication.shared.openSettings(
                        triggerFrom: triggerFrom
                    )
                    didOpenSettings()
                }
                // Don't show default browser card if this button is tapped
                Defaults[.didDismissDefaultBrowserCard] = true
            },
            onCancel: { [weak self] in
                self?.dismiss(animated: true) {
                    ClientLogger.shared.logCounter(
                        .DismissDefaultBrowserOnboardingScreen,
                        attributes: [
                            ClientLogCounterAttribute(
                                key: LogConfig.UIInteractionAttribute.openSysSettingTriggerFrom,
                                value: triggerFrom.rawValue
                            )
                        ]
                    )
                }

            },
            triggerFrom: triggerFrom
        )
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct DefaultBrowserInterstitialWelcomeScreen: View {
    @State private var switchToDefaultBrowserScreen = false

    var skipAction: () -> Void
    var buttonAction: () -> Void

    var body: some View {
        if switchToDefaultBrowserScreen {
            DefaultBrowserInterstitialOnboardingView(
                trigger: .defaultBrowserFirstScreen,
                skipAction: skipAction,
                buttonAction: buttonAction
            )
        } else {
            VStack(spacing: 0) {
                VStack(spacing: 30) {
                    Spacer().repeated(2)
                    VStack(alignment: .leading) {
                        Text("Welcome to Neeva")
                            .font(.system(size: 32, weight: .light))
                            .padding(.bottom, 5)
                        Text("The first ad-free, private search engine")
                            .withFont(.bodyLarge)
                    }

                    Image("default-browser-prompt", bundle: .main)
                        .resizable()
                        .frame(width: 300, height: 205)
                        .padding(.bottom, 32)
                    Spacer().repeated(2)
                    Button(
                        action: {
                            switchToDefaultBrowserScreen = true
                            ClientLogger.shared.logCounter(.GetStartedInWelcome)
                        },
                        label: {
                            Text("Get Started")
                                .withFont(.labelLarge)
                                .foregroundColor(.brand.white)
                                .padding(13)
                                .frame(maxWidth: .infinity)
                        }
                    )
                    .buttonStyle(.neeva(.primary))

                    Spacer()
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 35)
            .onAppear {
                if !Defaults[.firstRunImpressionLogged] {
                    ClientLogger.shared.logCounter(
                        .FirstRunImpression,
                        attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                    ConversionLogger.log(event: .launchedApp)
                    Defaults[.firstRunImpressionLogged] = true
                }
            }
        }
    }
}

// TODO merge this with the settings trigger as we are standardize the default browser screen now
public enum OpenDefaultBrowserOnboardingTrigger: String {
    case skipToBrowser
    case defaultBrowserFirstScreen
    case afterSignup
    case promoCard
    case settings
}

struct DefaultBrowserInterstitialOnboardingView: View {
    @State private var didTakeAction = false

    var trigger: OpenDefaultBrowserOnboardingTrigger = .afterSignup
    var showSkipButton: Bool = true

    var skipAction: () -> Void
    var buttonAction: () -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading) {
                Text("Make Neeva your Default Browser")
                    .font(.system(size: 32, weight: .light))

                Text(
                    "Block invasive trackers across the Web. Open links safely with blazing fast browsing and peace of mind."
                )
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(alignment: .leading) {
                Text("Follow these 3 easy steps:")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 32)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Symbol(decorative: .gear, size: 16)
                        .foregroundColor(.secondaryLabel)
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                        )
                    Text("1. Open Neeva Settings")
                        .withFont(.bodyXLarge)
                        .padding(.leading, 15)
                }
                Divider()
                HStack {
                    Symbol(decorative: .chevronForward, size: 16)
                        .foregroundColor(.secondaryLabel)
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                        )

                    Text("2. Tap Default Browser App")
                        .withFont(.bodyXLarge)
                        .padding(.leading, 15)
                }
                Divider()
                HStack {
                    Image("neevaMenuIcon")
                        .frame(width: 32, height: 32)
                        .background(Color(.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Text("3. Select Neeva")
                        .withFont(.bodyXLarge)
                        .padding(.leading, 15)
                }
            }.padding(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(UIColor.systemGray5), lineWidth: 5)
                )
                .padding(.horizontal, 16)

            Spacer()

            Button(
                action: {
                    buttonAction()
                    didTakeAction = true
                    ClientLogger.shared.logCounter(
                        .DefaultBrowserOnboardingInterstitialOpen,
                        attributes: [
                            ClientLogCounterAttribute(
                                key:
                                    LogConfig.PromoCardAttribute
                                    .defaultBrowserInterstitialTrigger,
                                value: trigger.rawValue
                            )
                        ]
                    )
                },
                label: {
                    Text("Open Neeva Settings")
                        .withFont(.labelLarge)
                        .foregroundColor(.brand.white)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(.neeva(.primary))
            .padding(.horizontal, 16)
            if showSkipButton {
                Button(
                    action: {
                        tapSkip()
                        didTakeAction = true
                    },
                    label: {
                        Text("Skip for Now")
                            .withFont(.labelLarge)
                            .foregroundColor(.ui.adaptive.blue)
                            .padding(13)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                    }
                )
                .padding(.top, 10)
                .padding(.bottom, 30)
            } else {
                Spacer()
            }
        }
        .onDisappear {
            if !didTakeAction {
                tapSkip()
            }
        }
        .padding(.bottom, 20)
    }

    private func tapSkip() {
        skipAction()
        ClientLogger.shared.logCounter(
            .DefaultBrowserOnboardingInterstitialSkip,
            attributes: [
                ClientLogCounterAttribute(
                    key:
                        LogConfig.PromoCardAttribute.defaultBrowserInterstitialTrigger,
                    value: trigger.rawValue
                )
            ]
        )
    }
}

struct DefaultBrowserInterstitialOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultBrowserInterstitialOnboardingView(
            skipAction: {
            },
            buttonAction: {
            }
        )
    }
}
