// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct TopBarNeevaMenuButton: View {
    let onTap: () -> Void
    let onNeevaMenuAction: (NeevaMenuAction) -> Void

    @Environment(\.isIncognito) private var isIncognito
    @EnvironmentObject var chromeModel: TabChromeModel

    // TODO: sync this state variable with TabToolbarView somehow
    @State private var presenting = false
    @State private var action: NeevaMenuAction?

    var body: some View {
        WithPopover(
            showPopover: $chromeModel.showNeevaMenuTourPrompt,
            popoverSize: CGSize(width: 300, height: 190),
            content: {
                TabToolbarButtons.NeevaMenu(iconWidth: 24) {
                    onTap()
                    presenting = true
                }
                .tapTargetFrame()
                .presentAsPopover(
                    isPresented: $presenting,
                    backgroundColor: .systemGroupedBackground,
                    arrowDirections: .up,
                    dismissOnTransition: true,
                    onDismiss: {
                        if let action = action {
                            onNeevaMenuAction(action)
                            self.action = nil
                        }
                    }
                ) {
                    VerticalScrollViewIfNeeded {
                        NeevaMenuView(menuAction: {
                            action = $0
                            presenting = false
                        })
                        .topBarPopoverPadding()
                        .environment(\.isIncognito, isIncognito)
                    }
                    .frame(minWidth: 340, minHeight: 323)
                }
            },
            popoverContent: {
                TourPromptView(
                    title: "Get the most out of Neeva!",
                    description: "Access your Neeva Home, Spaces, Settings, and more",
                    buttonMessage: "Let's take a Look!",
                    onConfirm: {
                        chromeModel.showNeevaMenuTourPrompt = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            presenting = true
                        }
                    },
                    onClose: {
                        chromeModel.showNeevaMenuTourPrompt = false
                        TourManager.shared.responseMessage(
                            for: TourManager.shared.getActiveStepName(), exit: true)
                    }
                )
            },
            staticColorMode: true
        )
    }
}

struct TopBarOverflowMenuButton: View {
    let changedUserAgent: Bool?
    let onOverflowMenuAction: (OverflowMenuAction, UIView) -> Void
    let location: OverflowMenuLocation

    @Environment(\.isIncognito) private var isIncognito

    // TODO: sync this state variable with TabToolbarView somehow
    @State private var presenting = false
    @State private var action: OverflowMenuAction?
    @State private var targetButtonView: UIView!

    @EnvironmentObject private var chromeModel: TabChromeModel
    @EnvironmentObject private var locationModel: LocationViewModel

    @ViewBuilder
    var content: some View {
        if location == .tab {
            OverflowMenuView(
                changedUserAgent: changedUserAgent ?? false,
                menuAction: {
                    action = $0
                    presenting = false
                }
            )
        } else {
            CardGridOverflowMenuView(
                changedUserAgent: changedUserAgent ?? false,
                menuAction: {
                    action = $0
                    presenting = false
                }
            )
        }
    }

    var body: some View {
        TabToolbarButtons.OverflowMenu(
            weight: .regular,
            action: {
                // Refesh feedback screenshot before presenting overflow menu
                if let tabManager = chromeModel.topBarDelegate?.tabManager {
                    SceneDelegate.getBVC(with: tabManager.scene).updateFeedbackImage()
                }
                presenting = true
                chromeModel.hideZeroQuery()
            }
        )
        .uiViewRef($targetButtonView)
        .tapTargetFrame()
        .presentAsPopover(
            isPresented: $presenting,
            arrowDirections: .up,
            dismissOnTransition: true,
            onDismiss: {
                if let action = action {
                    onOverflowMenuAction(action, targetButtonView)
                    self.action = nil
                }
            }
        ) {
            VerticalScrollViewIfNeeded {
                content
                    .environment(\.isIncognito, isIncognito)
                    .environmentObject(chromeModel)
                    .environmentObject(locationModel)
                    .topBarPopoverPadding()
            }.frame(minWidth: 340, minHeight: 285)
        }
    }
}

struct TopBarSpaceFilterButton: View {
    @EnvironmentObject var spaceCardModel: SpaceCardModel
    @State private var presenting = false

    var body: some View {
        TabToolbarButtons.SpaceFilter(weight: .regular) {
            presenting = true
        }
        .tapTargetFrame()
        .presentAsPopover(
            isPresented: $presenting,
            arrowDirections: .up,
            dismissOnTransition: true,
            onDismiss: {
                presenting = false
            }
        ) {
            VerticalScrollViewIfNeeded {
                SpacesFilterView()
                    .topBarPopoverPadding()
                    .environmentObject(spaceCardModel)
            }.frame(minWidth: 325, minHeight: 128)
        }
    }
}

/// see also `LocationViewShareButton`
struct TopBarShareButton: View {
    let url: URL?
    let onTap: (UIView) -> Void

    @State private var shareTargetView: UIView!
    @EnvironmentObject private var chromeModel: TabChromeModel

    var body: some View {
        TabToolbarButton(
            label: Symbol(.squareAndArrowUp, size: 20, label: "Share"),
            action: {
                onTap(shareTargetView)
            }
        )
        .uiViewRef($shareTargetView)
        .disabled(url == nil || !chromeModel.isPage)
    }
}

struct TopBarShareButton_Previews: PreviewProvider {
    static var previews: some View {
        TopBarShareButton(url: nil, onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: true))
        TopBarShareButton(url: "https://neeva.com", onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: false))

        TopBarShareButton(url: "https://neeva.com", onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: true))

        TopBarNeevaMenuButton(onTap: {}, onNeevaMenuAction: { _ in })
            .environmentObject(TabChromeModel())
    }
}

extension View {
    fileprivate func topBarPopoverPadding() -> some View {
        self
            .padding(.horizontal, -4)
            .padding(.top, 8)
    }
}
