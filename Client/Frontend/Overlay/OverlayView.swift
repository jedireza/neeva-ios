// Copyright Neeva. All rights reserved.

import SwiftUI

struct OverlayView: View {
    @ObservedObject var overlayManager: OverlayManager
    @State var safeArea: CGFloat = 0
    @State var keyboardHidden = true

    var isSheet: Bool {
        if let currentOverlay = overlayManager.currentOverlay,
            case OverlayType.sheet(_) = currentOverlay
        {
            return true
        }

        return false
    }

    @ViewBuilder
    var content: some View {
        switch overlayManager.currentOverlay {
        case .findInPage(let findInPage):
            VStack {
                Spacer()
                findInPage
                    .padding(.bottom, keyboardHidden ? 0 : -14)
            }.ignoresSafeArea(.container)
        case .notification(let notification):
            VStack {
                notification
                    .padding(.top, 12)
                Spacer()
            }
        case .popover(let popover):
            popover
        case .sheet(let sheet):
            sheet
        case .toast(let toast):
            VStack {
                Spacer()
                toast
                    .padding(.bottom, UIConstants.TopToolbarHeightWithToolbarButtonsShowing + 18)
            }
        default:
            EmptyView()
        }
    }

    var body: some View {
        GeometryReader { geom in
            content
                .offset(y: overlayManager.offset)
                .opacity(overlayManager.opacity)
                .animation(!isSheet || overlayManager.animationCompleted != nil ? .easeOut : nil)
                .onAnimationCompleted(for: overlayManager.animating) {
                    if let animationCompleted = overlayManager.animationCompleted {
                        animationCompleted()
                    }
                }
                .onChange(of: geom.safeAreaInsets.bottom) { newValue in
                    safeArea = geom.safeAreaInsets.bottom
                    keyboardHidden = safeArea < 100
                }
        }
    }
}
