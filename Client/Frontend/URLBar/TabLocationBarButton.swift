// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

struct TabLocationBarButton<Label: View>: View {
    let label: Label
    let action: () -> ()

    var body: some View {
        Button(action: action) {
            label
                .frame(width: TabLocationViewUX.height, height: TabLocationViewUX.height)
                .transition(.opacity)
        }.foregroundColor(.label)
    }
}

struct LocationViewTrackingButton: View {
    @State private var showingPopover = false
    @StateObject private var viewModel = TrackingStatsViewModel(
        trackers: TrackingEntity.getTrackingEntityURLsForCurrentTab(),
        settingsHandler: nil
    )

    var body: some View {
        TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template))
            { showingPopover = true }
            .presentAsPopover(
                isPresented: $showingPopover,
                backgroundColor: .PopupMenu.background
            ) {
                TrackingMenuView(
                    isTrackingProtectionEnabled: Defaults[.contentBlockingEnabled],
                    viewModel: viewModel
                )
            }
    }
}

struct LocationViewReloadButton: View {
    @Binding var state: ReloadButtonState
    let onTap: () -> ()

    var body: some View {
        if state != .disabled {
            TabLocationBarButton(
                label: state == .reload ? Symbol(.arrowClockwise) : Symbol(.xmark),
                action: onTap
            )
        }
    }
}

struct LocationViewShareButton: View {
    let url: URL?
    let canShare: Bool
    let onTap: (UIView) -> ()

    @State private var shareTargetView: UIView?

    var body: some View {
        if canShare, let url = url, !url.absoluteString.isEmpty {
            TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {
                if let shareTargetView = shareTargetView {
                    onTap(shareTargetView)
                } else {
                    print("nil sharetargetview!")
                }
            }
            .overlay(WrappingView(view: $shareTargetView).allowsHitTesting(false))
        }
    }

    fileprivate struct WrappingView: UIViewRepresentable {
        @Binding var view: UIView?
        func makeUIView(context: Context) -> some UIView {
            let view = UIView()
            view.isOpaque = false
            return view
        }
        func updateUIView(_ uiView: UIViewType, context: Context) {
            DispatchQueue.main.async {
                if uiView != self.view {
                    self.view = uiView
                }
            }
        }
    }
}

struct TabLocationBarButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LocationViewReloadButton(state: .constant(.disabled)) {}
            LocationViewReloadButton(state: .constant(.reload)) {}
            LocationViewReloadButton(state: .constant(.stop)) {}
        }
        HStack {
            LocationViewShareButton(url: nil, canShare: false, onTap: { _ in })
            LocationViewShareButton(url: URL(string: "https://neeva.com/"), canShare: false, onTap: { _ in })
            LocationViewShareButton(url: URL(string: "https://neeva.com/"), canShare: true, onTap: { _ in })
        }
    }
}

