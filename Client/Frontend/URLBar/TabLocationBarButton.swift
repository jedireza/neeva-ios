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
    @Environment(\.isIncognito) private var isIncognito
    @EnvironmentObject private var trackingStatsModel: TrackingStatsViewModel

    let currentDomain: String

    var body: some View {
        let label = isIncognito
            ? Image("incognito", label: Text("Tracking Protection, Incognito"))
            : Image("tracking-protection", label: Text("Tracking Protection"))
        TabLocationBarButton(label: label.renderingMode(.template)) {
            ClientLogger.shared.logCounter(.OpenShield, attributes: EnvironmentHelper.shared.getAttributes())
            showingPopover = true
        }
        .presentAsPopover(
            isPresented: $showingPopover,
            backgroundColor: .systemGroupedBackground,
            arrowDirections: [.up, .down]
        ) {
            TrackingMenuView(viewModel: trackingStatsModel)
        }
    }
}

struct LocationViewReloadButton: View {
    let buildMenu: () -> UIMenu?
    let state: URLBarModel.ReloadButtonState
    let onTap: () -> ()

    var body: some View {
        // TODO: when dropping support for iOS 14, change this to a Menu view with a primaryAction
        UIKitButton(action: onTap) {
            $0.tintColor = .label
            $0.setImage(Symbol.uiImage(state == .reload ? .arrowClockwise : .xmark), for: .normal)
            $0.accessibilityLabel = state == .reload ? .TabToolbarReloadAccessibilityLabel : .TabToolbarStopAccessibilityLabel
            $0.setDynamicMenu(buildMenu)
        }
        .frame(width: TabLocationViewUX.height, height: TabLocationViewUX.height)
    }
}

struct LocationViewShareButton: View {
    let url: URL?
    let onTap: (UIView) -> ()

    @State private var shareTargetView: UIView?

    var body: some View {
        if let url = url, !url.absoluteString.isEmpty {
            TabLocationBarButton(label: Symbol(.squareAndArrowUp, label: "Share")) {
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
            LocationViewTrackingButton(currentDomain: "neeva.com")
            LocationViewTrackingButton(currentDomain: "neeva.com")
                .environment(\.isIncognito, true)
        }.previewLayout(.sizeThatFits)
        HStack {
            LocationViewReloadButton(buildMenu: { UIMenu(children: [UIAction(title: "Hello, world!") { _ in }]) }, state: .reload) {}
            LocationViewReloadButton(buildMenu: { nil }, state: .stop) {}
        }.previewLayout(.sizeThatFits)
        HStack {
            LocationViewShareButton(url: nil, onTap: { _ in })
            LocationViewShareButton(url: "https://neeva.com/", onTap: { _ in })
        }.previewLayout(.sizeThatFits)
    }
}

