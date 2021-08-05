// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct FindInPageView: View {
    @EnvironmentObject var model: FindInPageModel

    let onDismiss: () -> Void

    public var body: some View {
        GroupedStack {
            CapsuleTextField(
                "Search Page", text: $model.searchValue,
                icon: Symbol(decorative: .magnifyingglass, style: .labelLarge))
                .accessibilityIdentifier("FindInPage_TextField")

            GroupedCell {
                HStack {
                    OverlaySheetStepperButton(action: model.previous,
                                              symbol: Symbol(.chevronUp, label: "Previous"),
                                              foregroundColor: .label)
                        .accessibilityIdentifier("FindInPage_Previous")

                    Spacer()

                    Text(model.matchIndex)
                        .withFont(.bodyLarge)
                        .accessibilityIdentifier("FindInPage_ResultsText")

                    Spacer()

                    OverlaySheetStepperButton(action: model.next,
                                              symbol: Symbol(.chevronDown, label: "Next"),
                                              foregroundColor: .label)
                        .accessibilityIdentifier("FindInPage_Next")
                }.padding(.horizontal, -GroupedCellUX.horizontalPadding)
            }
            .buttonStyle(TableCellButtonStyle())
            .modifier(OverlaySheetStepperAccessibilityModifier(accessibilityLabel: "Find on Page",
                                                  accessibilityValue: model.matchIndex,
                                                  increment: model.next,
                                                  decrement: model.previous))

            GroupedCellButton("Done", style: .labelLarge, action: onDismiss)
        }
    }
}

struct FindInPageView_Previews: PreviewProvider {
    static var previews: some View {
        FindInPageView(onDismiss: {})
    }
}
