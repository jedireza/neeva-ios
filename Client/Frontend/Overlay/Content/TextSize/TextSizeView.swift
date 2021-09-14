// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI
import WebKit

struct TextSizeView: View {
    @ObservedObject var model: TextSizeModel
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onDismiss) {
                Color.clear
                    .frame(maxHeight: .infinity)
            }.accessibilityHidden(true)

            GroupedStack {
                // all the content in here is decorative since the accessibility element is explicitly provided below.
                GroupedCell {
                    HStack {
                        OverlayStepperButton(
                            action: model.zoomOut,
                            symbol: Symbol(decorative: .minus, style: .bodyLarge),
                            foregroundColor: model.canZoomOut ? .label : .tertiaryLabel
                        )
                        .disabled(!model.canZoomOut)

                        Spacer()

                        Symbol(decorative: .textformatSize, style: .headingLarge)

                        Spacer()

                        OverlayStepperButton(
                            action: model.zoomIn,
                            symbol: Symbol(decorative: .plus, style: .bodyLarge),
                            foregroundColor: model.canZoomIn ? .label : .tertiaryLabel
                        )
                        .disabled(!model.canZoomIn)
                    }.padding(.horizontal, -GroupedCellUX.padding)
                }
                .buttonStyle(TableCellButtonStyle())
                .accessibilityElement(children: .ignore)
                .modifier(
                    OverlayStepperAccessibilityModifier(
                        accessibilityLabel: "Page Zoom",
                        accessibilityValue: model.label,
                        increment: model.zoomIn,
                        decrement: model.zoomOut))

                GroupedCellButton("Reset") { model.pageZoom = 1 }
                    .accentColor(.red)
                GroupedCellButton("Done", style: .labelLarge, action: onDismiss)
            }
            .background(
                Color.groupedBackground
                    .cornerRadius(GroupedCellUX.cornerRadius, corners: .top)
                    .ignoresSafeArea()
            )
            .background(
                RoundedRectangle(cornerRadius: GroupedCellUX.cornerRadius)
                    .fill(Color.black.opacity(0.12))
                    .blur(radius: 16)
                    .offset(y: 4)
            )
        }
    }
}

struct ZoomMenuView_Previews: PreviewProvider {
    private struct Preview: View {
        @ObservedObject var model: TextSizeModel
        var body: some View {
            TextSizeView(model: model, onDismiss: {})
                .overlay(Text(model.label))
        }
    }
    static var previews: some View {
        Preview(model: TextSizeModel(webView: WKWebView()))
    }
}
