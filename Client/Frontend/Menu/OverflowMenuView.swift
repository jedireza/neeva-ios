// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

private enum OverflowMenuUX {
    static let innerSectionPadding: CGFloat = 8
}

public struct OverflowMenuView: View {
    private let noTopPadding: Bool
    private let menuAction: ((OverflowMenuButtonActions) -> Void)?
    private let changedUserAgent: Bool

    @State private var openSpacesPrompt = false
    @State private var openFeedbackPrompt = false
    @State private var openSettingsPrompt = false
    @Environment(\.isIncognito) private var isIncognito
    @EnvironmentObject var tabToolBarModel: TabToolbarModel
    @EnvironmentObject var urlBarModel: URLBarModel

    public init(noTopPadding: Bool = false, changedUserAgent: Bool = false, menuAction: ((OverflowMenuButtonActions) -> Void)?) {
        self.noTopPadding = noTopPadding
        self.menuAction = menuAction
        self.changedUserAgent = changedUserAgent
    }

    public var body: some View {
        // TODO: when making significant updates, migrate to OverlayGroupedStack
        VStack(alignment: .leading, spacing: GroupedCellUX.spacing) {
            VStack(spacing: OverflowMenuUX.innerSectionPadding) {
                HStack(spacing: OverflowMenuUX.innerSectionPadding) {
                    NeevaMenuButtonView(label: "Forward", symbol: .arrowRight) {
                        self.menuAction!(OverflowMenuButtonActions.forward)
                    }
                    .accessibilityIdentifier("NeevaMenu.Forward")
                    .disabled(!tabToolBarModel.canGoForward)

                    NeevaMenuButtonView(label: urlBarModel.reloadButton == .reload ? "Reload" : "Stop", symbol: urlBarModel.reloadButton == .reload ? .arrowClockwise : .xmark) {
                        self.menuAction!(OverflowMenuButtonActions.reload)
                    }
                    .accessibilityIdentifier("NeevaMenu.Reload")

                    NeevaMenuButtonView(label: "New Tab", symbol: .plus) {
                        self.menuAction!(OverflowMenuButtonActions.newTab)
                    }
                    .accessibilityIdentifier("NeevaMenu.NewTab")
                }
            }

            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    NeevaMenuRowButtonView(label: "Find on Page", symbol: .docTextMagnifyingglass) {
                        self.menuAction!(OverflowMenuButtonActions.findOnPage)
                    }
                    .accessibilityIdentifier("NeevaMenu.FindOnPage")

                    Color.groupedBackground.frame(height: 1)

                    NeevaMenuRowButtonView(label: "Text Size", symbol: .textformatSize) {
                        self.menuAction!(OverflowMenuButtonActions.textSize)
                    }
                    .accessibilityIdentifier("NeevaMenu.TextSize")

                    Color.groupedBackground.frame(height: 1)

                    /*
                    NeevaMenuRowButtonView(label: "Open Reading Mode", symbol: .docText) {
                        self.menuAction!(OverflowMenuButtonActions.readingMode)
                    }
                    .accessibilityIdentifier("NeevaMenu.OpenReadingMode")

                    Color.groupedBackground.frame(height: 1)
 */

                    NeevaMenuRowButtonView(label: changedUserAgent == true
                        ? Strings.AppMenuViewMobileSiteTitleString : Strings.AppMenuViewDesktopSiteTitleString, symbol: .desktopcomputer) {
                        self.menuAction!(OverflowMenuButtonActions.desktopSite)
                    }
                    .accessibilityIdentifier("NeevaMenu.RequestDesktopSite")

                    Color.groupedBackground.frame(height: 1)
                }
            }
        }
        .padding(self.noTopPadding ? [.leading, .trailing] : [.leading, .trailing, .top], 16)
        .background(Color.groupedBackground)
        .onAppear(perform: viewDidAppear)
        .onDisappear(perform: viewDidDisappear)
        .accentColor(.label)
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

struct OverflowMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuView(menuAction: nil).previewDevice("iPod touch (7th generation)").environment(
            \.sizeCategory, .extraExtraExtraLarge)
        NeevaMenuView(menuAction: nil).environment(\.isIncognito, true)
    }
}
