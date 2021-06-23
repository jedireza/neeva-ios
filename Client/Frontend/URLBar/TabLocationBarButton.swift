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
        trackers: TrackingEntity.getTrackingEntityURLsForCurrentTab()
    )
    @Environment(\.isIncognito) var isIncognito

    var body: some View {
        let label = isIncognito
            ? Image("incognito", label: Text("Tracking Protection, Incognito"))
            : Image("tracking-protection", label: Text("Tracking Protection"))
        TabLocationBarButton(label: label.renderingMode(.template))
            { showingPopover = true }
            .presentAsPopover(
                isPresented: $showingPopover,
                backgroundColor: .PopupMenu.background
            ) {
                TrackingMenuView(viewModel: viewModel)
            }
    }
}

struct LocationViewReloadButton: View {
    let buildMenu: () -> UIMenu?
    @Binding var state: ReloadButtonState
    let onTap: () -> ()

    var body: some View {
        if state != .disabled {
            Content(buildMenu: buildMenu, state: state, onTap: onTap)
                .frame(width: TabLocationViewUX.height, height: TabLocationViewUX.height)
        }
    }

    struct Content: UIViewRepresentable {
        let buildMenu: () -> UIMenu?
        let state: ReloadButtonState
        let onTap: () -> ()

        class Coordinator {
            var onTap: () -> ()
            init(onTap: @escaping () -> ()) {
                self.onTap = onTap
            }

            @objc func action() {
                onTap()
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(onTap: onTap)
        }

        func makeUIView(context: Context) -> UIButton {
            let button = UIButton()
            button.tintColor = .label
            button.addTarget(context.coordinator, action: #selector(Coordinator.action), for: .primaryActionTriggered)
            return button
        }

        func updateUIView(_ button: UIButton, context: Context) {
            button.setImage(
                UIImage(systemSymbol: state == .reload ? .arrowClockwise : .xmark)
                    .withConfiguration(UIImage.SymbolConfiguration(weight: .medium)),
                for: .normal
            )
            button.accessibilityLabel = state == .reload ? .TabToolbarReloadAccessibilityLabel : .TabToolbarStopAccessibilityLabel
            button.setDynamicMenu(buildMenu)
            context.coordinator.onTap = onTap
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
            LocationViewReloadButton(buildMenu: { nil }, state: .constant(.disabled)) {}
            LocationViewReloadButton(buildMenu: { UIMenu(children: [UIAction(title: "Hello, world!") { _ in }]) }, state: .constant(.reload)) {}
            LocationViewReloadButton(buildMenu: { nil }, state: .constant(.stop)) {}
        }
        HStack {
            LocationViewShareButton(url: nil, canShare: false, onTap: { _ in })
            LocationViewShareButton(url: "https://neeva.com/", canShare: false, onTap: { _ in })
            LocationViewShareButton(url: "https://neeva.com/", canShare: true, onTap: { _ in })
        }
    }
}

