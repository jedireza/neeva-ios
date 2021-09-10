// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct SpacesIntroOverlaySheetContent: View {
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet
    var body: some View {
        SpacesIntroView(dismiss: hideOverlaySheet)
            .overlaySheetIsFixedHeight(isFixedHeight: true)
    }
}

struct SpacesIntroView: View {
    let learnMoreURL = URL(
        string: "https://help.neeva.com/hc/en-us/articles/1500005917202-What-are-Spaces")!
    let dismiss: () -> Void
    @Environment(\.onOpenURL) private var onOpenURL

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
            Image("spaces-intro", bundle: .main)
                .resizable()
                .frame(width: 214, height: 200)
                .padding(32)
                .accessibilityLabel(
                    "Stay organized by adding images, websites, documents to a Space today")
            Text("Kill the clutter").withFont(.headingXLarge).padding(8)
            Text(
                "Save and share instantly. Stay organized by adding images, websites, documents to a Space today"
            )
            .withFont(.bodyLarge)
            .lineLimit(3)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .fixedSize(horizontal: false, vertical: true)
            Button(
                action: {
                    dismiss()
                },
                label: {
                    Text("Continue")
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
        SpacesIntroView(dismiss: {})
        EmptySpaceView()
    }
}
