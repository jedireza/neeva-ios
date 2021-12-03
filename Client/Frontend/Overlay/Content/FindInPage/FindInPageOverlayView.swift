// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct FindInPageViewUX {
    static let height: CGFloat = 75
}

struct FindInPageView: View {
    @EnvironmentObject var model: FindInPageModel
    let onDismiss: () -> Void

    public var body: some View {
        VStack {
            HStack {
                SingleLineTextField(
                    icon: Symbol(decorative: .magnifyingglass, style: .labelLarge),
                    placeholder: "Search Page",
                    text: $model.searchValue,
                    alwaysShowClearButton: false,
                    detailText: model.matchIndex,
                    focusTextField: true
                ).accessibilityIdentifier("FindInPage_TextField")

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

            Spacer()
        }.frame(height: FindInPageViewUX.height).padding(.bottom, 28)
    }
}

struct FindInPageView_Previews: PreviewProvider {
    static var previews: some View {
        FindInPageView(onDismiss: {})
            .environmentObject(FindInPageModel(tab: nil))
    }
}
