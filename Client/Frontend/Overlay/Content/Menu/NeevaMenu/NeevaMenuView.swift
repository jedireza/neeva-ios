// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

enum NeevaMenuUX {
    static let innerSectionPadding: CGFloat = 8
    static let bottomPadding: CGFloat = 24
}

struct NeevaMenuWillMoveView: View {
    @Default(.showNeevaMenuWillMove) var showNeevaMenuWillMove

    @Environment(\.colorScheme) var colorScheme

    let closeButtonImage: UIImage = UIImage(systemName: "xmark")!

    var body: some View {
        if showNeevaMenuWillMove {
            HStack {
                Text(
                    "This menu is moving soon! You'll find its new home in \(Image(systemName: "ellipsis.circle")). Happy Neeva-ing!"
                )
                .withFont(.bodyLarge)
                .foregroundColor(Color.label)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

                Spacer()

                closeButton
                    .scaledToFit()
            }
            .padding(20)
            .background(colorScheme == .dark ? Color.brand.variant.gold : Color.brand.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    var closeButton: some View {
        Button(action: {
            showNeevaMenuWillMove = false
        }) {
            Image(uiImage: closeButtonImage)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundColor(.secondaryLabel)
                .padding(6)
                .frame(width: 24, height: 24)
                .background(Color(UIColor.systemGray6))
                .clipShape(Circle())
        }
    }
}

struct NeevaMenuView: View {
    private let menuAction: (NeevaMenuAction) -> Void

    @State private var openSpacesPrompt = false
    @State private var openFeedbackPrompt = false
    @State private var openSettingsPrompt = false
    @EnvironmentObject private var incognitoModel: IncognitoModel

    init(menuAction: @escaping (NeevaMenuAction) -> Void) {
        self.menuAction = menuAction
    }

    var body: some View {
        GroupedStack {
            HStack(spacing: NeevaMenuUX.innerSectionPadding) {
                GroupedButtonView(label: "Home", nicon: .house) {
                    self.menuAction(.home)
                }
                .accessibilityIdentifier("NeevaMenu.Home")
                .disabled(incognitoModel.isIncognito)

                WithPopover(
                    showPopover: $openSpacesPrompt,
                    popoverSize: CGSize(width: 290, height: 150),
                    content: {
                        GroupedButtonView(label: "Spaces", nicon: .bookmarkOnBookmark) {
                            self.menuAction(.spaces)
                        }
                        .accessibilityIdentifier("NeevaMenu.Spaces")
                        .disabled(incognitoModel.isIncognito)
                    },
                    popoverContent: {
                        TourPromptView(
                            title: "Want to be organized?",
                            description:
                                "Save web pages, images, and videos to a curated Space for easy access later",
                            onClose: onCloseTourPrompt, staticColorMode: true)
                    },
                    staticColorMode: true
                )
            }

            HStack(spacing: NeevaMenuUX.innerSectionPadding) {
                WithPopover(
                    showPopover: $openSettingsPrompt,
                    popoverSize: CGSize(width: 290, height: 180),
                    content: {
                        GroupedButtonView(label: "Settings", nicon: .gear) {
                            self.menuAction(.settings)
                        }
                        .accessibilityIdentifier("NeevaMenu.Settings")
                    },
                    popoverContent: {
                        TourPromptView(
                            title: "Want to search personal documents?",
                            description:
                                "Search information in your email, online files and folders, and calendar!",
                            onClose: onCloseTourPrompt, staticColorMode: true)
                    },
                    staticColorMode: true
                )

                WithPopover(
                    showPopover: $openFeedbackPrompt,
                    popoverSize: CGSize(width: 290, height: 120),
                    content: {
                        GroupedButtonView(label: "Support", symbol: .bubbleLeft) {
                            self.menuAction(.support)
                        }
                        .accessibilityIdentifier("NeevaMenu.Feedback")
                    },
                    popoverContent: {
                        TourPromptView(
                            title: "Have feedback?",
                            description: "We'd love to hear your thoughts!",
                            onClose: onCloseTourPrompt, staticColorMode: true)
                    },
                    staticColorMode: true
                )
            }

            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    if NeevaFeatureFlags[.referralPromo] {
                        GroupedRowButtonView(
                            label: "Win $5000 by inviting friends", isPromo: true
                        ) {
                            self.menuAction(.referralPromo)
                        }
                        .accentColor(Color.brand.adaptive.orange)
                        .accessibilityIdentifier("NeevaMenu.ReferralPromo")

                        Color.groupedBackground.frame(height: 1)
                    }

                    GroupedRowButtonView(label: "History", symbol: .clock) {
                        self.menuAction(.history)
                    }
                    .accessibilityIdentifier("NeevaMenu.History")

                    Color.groupedBackground.frame(height: 1)

                    GroupedRowButtonView(label: "Downloads", symbol: .squareAndArrowDown) {
                        ClientLogger.shared.logCounter(
                            .OpenDownloads, attributes: EnvironmentHelper.shared.getAttributes())
                        openDownloadsFolderInFilesApp()
                    }
                    .accessibilityIdentifier("NeevaMenu.Downloads")
                }
            }.accentColor(.label)
        }
        .onAppear(perform: viewDidAppear)
        .onDisappear(perform: viewDidDisappear)
    }

    func onCloseTourPrompt() {
        openSpacesPrompt = false
        openFeedbackPrompt = false
        openSettingsPrompt = false

        if TourManager.shared.hasActiveStep() {
            TourManager.shared.responseMessage(
                for: TourManager.shared.getActiveStepName(), exit: true)
        }
    }

    func viewDidAppear() {
        DispatchQueue.main.async {
            updateTourPrompts()
        }
    }

    private func updateTourPrompts() {
        if TourManager.shared.hasActiveStep() {
            switch TourManager.shared.getActiveStepName() {
            case .promptSpaceInNeevaMenu:
                self.openSpacesPrompt.toggle()
            case .promptFeedbackInNeevaMenu:
                self.openFeedbackPrompt.toggle()
            case .promptSettingsInNeevaMenu:
                self.openSettingsPrompt.toggle()
            default:
                break
            }
        }
    }

    private func viewDidDisappear() {
        TourManager.shared.notifyCurrentViewClose()
    }
}

struct NeevaMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuView(menuAction: { _ in }).previewDevice("iPod touch (7th generation)")
            .environment(
                \.sizeCategory, .extraExtraExtraLarge)
        NeevaMenuView(menuAction: { _ in }).environmentObject(IncognitoModel(isIncognito: true))
    }
}
