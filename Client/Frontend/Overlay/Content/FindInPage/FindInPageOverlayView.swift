// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct FindInPageView: View {
    @EnvironmentObject var model: FindInPageModel
    @State var bottomPadding: CGFloat = 1

    let onDismiss: () -> Void

    public var body: some View {
        HStack {
            CapsuleTextField(
                icon: Symbol(decorative: .magnifyingglass, style: .labelLarge),
                placeholder: "Search Page",
                text: $model.searchValue,
                alwaysShowClearButton: false,
                detailText: model.matchIndex,
                focusTextField: true
            ) { isEditing in
                bottomPadding = isEditing ? 10 : 1
            }
            .accessibilityIdentifier("FindInPage_TextField")

            HStack {
                OverlayStepperButton(
                    action: model.previous,
                    symbol: Symbol(.chevronUp, style: .headingMedium, label: "Previous"),
                    foregroundColor: .ui.adaptive.blue
                )
                .accessibilityIdentifier("FindInPage_Previous")

                OverlayStepperButton(
                    action: model.next,
                    symbol: Symbol(.chevronDown, style: .headingMedium, label: "Next"),
                    foregroundColor: .ui.adaptive.blue
                )
                .accessibilityIdentifier("FindInPage_Next")
            }

            Button(action: onDismiss) {
                Text("Done")
            }
            .accessibilityIdentifier("FindInPage_Done")
        }
        .padding(.horizontal)
        .padding(.bottom, bottomPadding + 10)
    }
}

struct FindInPageView_Previews: PreviewProvider {
    static var previews: some View {
        FindInPageView(onDismiss: {})
            .environmentObject(FindInPageModel(tabManager: SceneDelegate.getTabManager(for: nil)))
    }
}
