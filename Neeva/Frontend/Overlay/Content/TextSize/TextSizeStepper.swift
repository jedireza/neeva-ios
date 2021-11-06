// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct TextSizeStepper: View {
    var roundedCorners: UIRectCorner = .allCorners
    @ObservedObject var model: TextSizeModel

    var body: some View {
        GroupedCell(
            content: {
                HStack {
                    OverlayStepperButton(
                        action: model.zoomOut,
                        symbol: Symbol(decorative: .minus, style: .bodyLarge),
                        foregroundColor: model.canZoomOut ? .label : .tertiaryLabel
                    )
                    .disabled(!model.canZoomOut)

                    Spacer()

                    Button {
                        model.pageZoom = 1
                    } label: {
                        Symbol(decorative: .textformatSize, style: .headingLarge)
                            .foregroundColor(.label)
                    }

                    Spacer()

                    OverlayStepperButton(
                        action: model.zoomIn,
                        symbol: Symbol(decorative: .plus, style: .bodyLarge),
                        foregroundColor: model.canZoomIn ? .label : .tertiaryLabel
                    )
                    .disabled(!model.canZoomIn)
                }.padding(.horizontal, -GroupedCellUX.padding)
            }, roundedCorners: roundedCorners
        )
        .buttonStyle(TableCellButtonStyle())
        .accessibilityElement(children: .ignore)
        .modifier(
            OverlayStepperAccessibilityModifier(
                accessibilityLabel: "Page Zoom",
                accessibilityValue: model.label,
                increment: model.zoomIn,
                decrement: model.zoomOut))
    }
}
