// Copyright Neeva. All rights reserved.

import SwiftUI

/// A SwiftUI wrapper for a `UIButton`.
/// **TODO**: when dropping support for iOS 14, change all call sites to a `Menu` with a `primaryAction`
struct SecondaryMenuButton: UIViewRepresentable {
    /// The type of the button, such as `.system`
    let buttonType: UIButton.ButtonType
    /// Called on every render to apply customizations such as labels, menus, or coloring
    let customize: (DynamicMenuButton) -> Void
    /// The action to perform when the button is tapped
    let action: () -> Void

    init(
        type: UIButton.ButtonType = .system, action: @escaping () -> Void,
        customize: @escaping (DynamicMenuButton) -> Void
    ) {
        self.buttonType = type
        self.customize = customize
        self.action = action
    }

    /// Helper class that can participate in target-action-based event handling for the button.
    class Coordinator {
        var onTap: () -> Void
        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        @objc func action() {
            onTap()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: action)
    }

    func makeUIView(context: Context) -> DynamicMenuButton {
        let button = DynamicMenuButton(type: buttonType)
        button.addTarget(
            context.coordinator, action: #selector(Coordinator.action), for: .primaryActionTriggered
        )
        return button
    }

    func updateUIView(_ button: DynamicMenuButton, context: Context) {
        customize(button)
        context.coordinator.onTap = action
    }
}

struct SecondaryMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryMenuButton(action: {}) {
            $0.setTitle("Hello, world", for: .normal)
            $0.setDynamicMenu {
                UIMenu(children: [
                    UIAction(title: "Item 1") { _ in },
                    UIAction(title: "Item 2") { _ in },
                    UIAction(title: "Item 3") { _ in },
                ])
            }
        }
    }
}
