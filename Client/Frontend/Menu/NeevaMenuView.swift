// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

public struct NeevaMenuView: View {
    private let noTopPadding: Bool
    private let menuAction: ((NeevaMenuButtonActions) -> ())?

    @State private var openSpacesPrompt = false
    @State private var openFeedbackPrompt = false
    @State private var openSettingsPrompt = false
    @Environment(\.isIncognito) private var isIncognito

    public init(noTopPadding: Bool = false, menuAction: ((NeevaMenuButtonActions) -> ())?) {
        self.noTopPadding = noTopPadding
        self.menuAction = menuAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: NeevaUIConstants.menuSectionPadding) {
            VStack(spacing: NeevaUIConstants.menuInnerSectionPadding) {
                HStack(spacing: NeevaUIConstants.menuInnerSectionPadding){
                    Button {
                        self.menuAction!(NeevaMenuButtonActions.home)
                    } label: {
                        NeevaMenuButtonView(label: "Home", nicon: .house, isDisabled: isIncognito)
                    }
                    .accessibilityIdentifier("NeevaMenu.Home")
                    .disabled(isIncognito)
                    WithPopover(
                        showPopover: $openSpacesPrompt,
                        popoverSize: CGSize(width:290, height: 150),
                        content: {
                            Button {
                                self.menuAction!(NeevaMenuButtonActions.spaces)
                            } label: {
                                NeevaMenuButtonView(label: "Spaces", nicon: .bookmarkOnBookmark, isDisabled: isIncognito)
                            }
                            .accessibilityIdentifier("NeevaMenu.Spaces")
                            .disabled(isIncognito)
                        },
                        popoverContent: {
                            TourPromptView(title: "Want to be organized?", description: "Save web pages, images, and videos to a curated Space for easy access later", onClose: onCloseTourPrompt)
                        })

                }
                .background(Color.clear)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)

                HStack(spacing: NeevaUIConstants.menuInnerSectionPadding){
                    WithPopover(
                        showPopover: $openSettingsPrompt,
                        popoverSize: CGSize(width:290, height: 180),
                        content: {
                            Button {
                                self.menuAction!(NeevaMenuButtonActions.settings)
                            } label: {
                                NeevaMenuButtonView(label: "Settings", nicon: .gear)
                            }
                            .accessibilityIdentifier("NeevaMenu.Settings")
                        },
                        popoverContent: {
                            TourPromptView(title: "Want to search personal documents?", description: "Search information in your email, online files and folders, and calendar!", onClose: onCloseTourPrompt)
                        })

                    WithPopover(
                        showPopover: $openFeedbackPrompt,
                        popoverSize: CGSize(width:290, height: 120),
                        content: {
                            Button {
                                self.menuAction!(NeevaMenuButtonActions.feedback)
                            } label: {
                                NeevaMenuButtonView(label: "Feedback", symbol: .bubbleLeft)
                            }
                            .accessibilityIdentifier("NeevaMenu.Feedback")
                        },
                        popoverContent: {
                            TourPromptView(title: "Have feedback?", description: "We'd love to hear your thoughts!", onClose: onCloseTourPrompt)
                        })
                }
                .background(Color.clear)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)
            }

            VStack(spacing: 0) {
                Button {
                    self.menuAction!(NeevaMenuButtonActions.history)
                } label: {
                    NeevaMenuRowButtonView(label:"History", symbol: .clock)
                        .padding([.leading, .top, .bottom], NeevaUIConstants.buttonInnerPadding)
                        .padding(.trailing, NeevaUIConstants.buttonInnerPadding - 6)
                }
                .accessibilityIdentifier("NeevaMenu.History")

                Divider()

                Button {
                    self.menuAction!(NeevaMenuButtonActions.downloads)
                } label: {
                    NeevaMenuRowButtonView(label:"Downloads", symbol: .squareAndArrowDown)
                        .padding([.leading, .top, .bottom], NeevaUIConstants.buttonInnerPadding)
                        .padding(.trailing, NeevaUIConstants.buttonInnerPadding - 6)
                }
                .accessibilityIdentifier("NeevaMenu.Downloads")
            }
            .padding(0)
            .background(Color(UIColor.PopupMenu.foreground))
            .cornerRadius(NeevaUIConstants.menuCornerDefault)
        }
        .padding(self.noTopPadding ? [.leading, .trailing] : [.leading, .trailing, .top], NeevaUIConstants.menuOuterPadding)
        .background(Color(UIColor.PopupMenu.background))
        .onAppear(perform: viewDidAppear)
        .onDisappear(perform: viewDidDisappear)
    }

    func onCloseTourPrompt() {
        openSpacesPrompt = false
        openFeedbackPrompt = false
        openSettingsPrompt = false

        if TourManager.shared.hasActiveStep() {
            TourManager.shared.responseMessage(for: TourManager.shared.getActiveStepName(), exit: true)
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
        NeevaMenuView(menuAction: nil)
        NeevaMenuView(menuAction: nil).environment(\.isIncognito, true)
    }
}
