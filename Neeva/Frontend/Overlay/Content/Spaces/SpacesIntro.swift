// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct SpacesIntroOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    let learnMoreURL = URL(
        string: "https://help.neeva.com/hc/en-us/articles/1500005917202-What-are-Spaces")!
    @Environment(\.onOpenURL) private var onOpenURL
    var body: some View {
        SpacesIntroView(
            dismiss: hideOverlaySheet,
            imageName: "spaces-intro",
            imageAccessibilityLabel:
                "Stay organized by adding images, websites, documents to a Space today",
            headlineText: "Kill the clutter",
            detailText:
                "Save and share instantly. Stay organized by adding images, websites, documents to a Space today",
            firstButtonText: "Continue",
            secondButtonText: "Learn More About Spaces",
            firstButtonPressed: hideOverlaySheet,
            secondButtonPressed: {
                onOpenURL(learnMoreURL)
            }
        )
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}

struct SpacesShareIntroOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    let onShare: () -> Void
    var body: some View {
        SpacesIntroView(
            dismiss: hideOverlaySheet,
            imageName: "spaces-share-intro",
            imageAccessibilityLabel:
                "Stay organized by adding images, websites, documents to a Space today",
            headlineText: "Share Space to the web",
            detailText:
                "Your Space will be public as anyone with the link can view your Space. Ready to share?",
            firstButtonText: "Yes! Share my Space publicly",
            secondButtonText: "Not now",
            firstButtonPressed: {
                onShare()
                hideOverlaySheet()
            },
            secondButtonPressed: hideOverlaySheet
        )
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}

struct SpacesIntroView: View {
    let dismiss: () -> Void
    let imageName: String
    let imageAccessibilityLabel: String
    let headlineText: String
    let detailText: String
    let firstButtonText: String
    let secondButtonText: String
    let firstButtonPressed: () -> Void
    let secondButtonPressed: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Symbol(.xmark, style: .headingMedium, label: "Close")
                        .foregroundColor(.tertiaryLabel)
                        .tapTargetFrame()
                        .padding(.trailing, 4.5)
                }
            }
            Image(imageName, bundle: .main)
                .resizable()
                .frame(width: 214, height: 200)
                .padding(32)
                .accessibilityLabel(imageAccessibilityLabel)
            Text(headlineText).withFont(.headingXLarge).padding(8)
            Text(detailText)
                .withFont(.bodyLarge)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)
            Button(
                action: firstButtonPressed,
                label: {
                    Text(firstButtonText)
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
                action: secondButtonPressed,
                label: {
                    Text(secondButtonText)
                        .withFont(.labelLarge)
                        .foregroundColor(.ui.adaptive.blue)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                }
            ).padding(.top, 10)
        }.padding(.bottom, 20)
    }
}

struct EmptySpaceView: View {
    let learnMoreURL = URL(
        string: "https://help.neeva.com/hc/en-us/articles/1500005917202-What-are-Spaces")!
    @Environment(\.onOpenURL) private var onOpenURL
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var toolbarModel: SwitcherToolbarModel

    var body: some View {
        Color.ui.adaptive.separator.frame(height: 1)
        VStack(spacing: 0) {
            Spacer()
            Image("empty-space", bundle: .main)
                .resizable()
                .frame(width: 214, height: 200)
                .padding(28)
                .accessibilityLabel(
                    "Use bookmark icon on a search result or website to add to your Space")
            (Text(
                "Tap") + Text(" \u{10025E} ").font(Font.custom("nicons-400", size: 20))
                + Text(
                    "on a search result or website to add to your Space"
                ))
                .withFont(.bodyLarge)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)
            Button(
                action: {
                    spacesModel.detailedSpace = nil
                    toolbarModel.openLazyTab()
                },
                label: {
                    Text("Start Searching")
                        .withFont(.labelLarge)
                        .frame(maxWidth: .infinity)
                        .clipShape(Capsule())
                }
            )
            .buttonStyle(NeevaButtonStyle(.primary))
            .padding(.top, 36)
            .padding(.horizontal, 16)
            Button(
                action: {
                    spacesModel.detailedSpace = nil
                    gridModel.hideWithNoAnimation()
                    onOpenURL(learnMoreURL)
                },
                label: {
                    Text("Learn More About Spaces")
                        .withFont(.labelLarge)
                        .foregroundColor(.ui.adaptive.blue)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                }
            ).padding(.top, 10)
            Spacer()
        }
        .background(Color.background)
        .ignoresSafeArea()
    }
}

struct SpacesIntroView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpacesIntroOverlayContent().preferredColorScheme(.dark).environment(\.hideOverlay, {})
            SpacesIntroOverlayContent().environment(\.hideOverlay, {})
        }
        SpacesShareIntroOverlayContent(onShare: {}).environment(\.hideOverlay, {})
        EmptySpaceView()
    }
}
