// Copyright Neeva. All rights reserved.

import Combine
import Shared
import SwiftUI

struct ShareAddedSpaceView: View {
    @Environment(\.hideOverlay) private var hideOverlay

    @State var subscription: AnyCancellable? = nil
    @State var refreshing = false
    @State var presentingShareUI: Bool = true
    @ObservedObject var request: AddToSpaceRequest
    let bvc: BrowserViewController

    private var space: Space? {
        SpaceStore.shared.allSpaces.first(where: {
            $0.id.id == request.targetSpaceID
        })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(
                    systemSymbol: request.state == .savingToSpace
                        ? .checkmarkCircle : .checkmarkCircleFill
                )
                .foregroundColor(.label)
                .frame(width: 24, height: 24)
                Text(
                    request.state == .savingToSpace
                        ? request.textInfo.0 : request.textInfo.1
                )
                .foregroundColor(.label)
                .withFont(.bodyLarge)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .animation(nil)
            if request.state == .savedToSpace {
                HStack {
                    Spacer()
                    Button(
                        action: {
                            bvc.cardGridViewController.rootView.openSpace(
                                spaceID: request.targetSpaceID!)
                            hideOverlay()
                        },
                        label: {
                            Text("Open Space")
                                .foregroundColor(refreshing ? .tertiaryLabel : .ui.adaptive.blue)
                                .withFont(.bodyLarge)
                                .disabled(refreshing)
                        })
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                if let space = space, space.ACL == .owner || space.isPublic {
                    Color.TrayBackground.frame(height: 2)
                    Text("Share Space")
                        .withFont(.headingSmall)
                        .foregroundColor(.secondaryLabel)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .background(Color.DefaultBackground)
                }
                if let space = space {
                    ShareSpaceView(
                        space: space, shareTarget: bvc.topBar.view, isPresented: $presentingShareUI,
                        compact: true,
                        noteText:
                            "Just added \"\(request.title)\" to my \"\(request.targetSpaceName!)\" Space."
                    )
                } else {
                    Spacer().frame(height: 210)
                }
            }
        }
        .animation(.easeInOut)
        .environment(
            \.shareURL,
            { [unowned bvc] url, view in
                let helper = ShareExtensionHelper(url: url, tab: nil)
                let controller = helper.createActivityViewController({ (_, _) in })
                if UIDevice.current.userInterfaceIdiom != .pad {
                    controller.modalPresentationStyle = .formSheet
                } else {
                    controller.popoverPresentationController?.sourceView = view
                    controller.popoverPresentationController?.permittedArrowDirections = .up
                }

                bvc.present(controller, animated: true, completion: nil)
            }
        ).environmentObject(bvc.cardGridViewController.rootView.spaceCardModel)
        .environmentObject(bvc.cardGridViewController.rootView.tabCardModel)
        .onChange(of: presentingShareUI) { _ in
            hideOverlay()
        }.onChange(of: request.state) { state in
            if case .savedToSpace = state {
                SpaceStore.shared.refresh()
                refreshing = true
                subscription = SpaceStore.shared.$state.sink { state in
                    if case .ready = state {
                        refreshing = false
                        subscription?.cancel()
                    } else if case .failed = state {
                        refreshing = false
                        subscription?.cancel()
                    }
                }
            }
        }
    }
}
