// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import WebKit

struct ZoomMenuView: View {
    @ObservedObject var model: ZoomMenuModel
    let onDismiss: () -> ()

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onDismiss) {
                Color.clear
                    .frame(maxHeight: .infinity)
            }.accessibilityHidden(true)

            GroupedStack {
                GroupedCell {
                    HStack {
                        Button(action: model.zoomOut) {
                            Symbol(.minus, style: .bodyLarge)
                                .frame(width: GroupedCellUX.minCellHeight, height: GroupedCellUX.minCellHeight)
                                .foregroundColor(model.canZoomOut ? .label : .tertiaryLabel)
                        }.disabled(!model.canZoomOut)
                        Spacer()
                        Symbol(.textformatSize, style: .headingLarge)
                        Spacer()
                        Button(action: model.zoomIn) {
                            Symbol(.plus, style: .bodyLarge)
                                .frame(width: GroupedCellUX.minCellHeight, height: GroupedCellUX.minCellHeight)
                                .foregroundColor(model.canZoomIn ? .label : .tertiaryLabel)
                        }.disabled(!model.canZoomIn)
                    }.padding(.horizontal, -GroupedCellUX.horizontalPadding)
                }
                .buttonStyle(TableCellButtonStyle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Page Zoom")
                .accessibilityValue(model.label)
                .accessibilityAdjustableAction { action in
                    switch action {
                    case .increment: model.zoomIn()
                    case .decrement: model.zoomOut()
                    @unknown default: break
                    }
                }

                GroupedCellButton("Reset") { model.pageZoom = 1 }
                    .accentColor(.red)
                GroupedCellButton("Done", style: .labelLarge, action: onDismiss)
            }
            .cornerRadius(GroupedCellUX.cornerRadius, corners: .top)
            .ignoresSafeArea()
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
        @ObservedObject var model: ZoomMenuModel
        var body: some View {
            ZoomMenuView(model: model, onDismiss: {})
                .overlay(Text(model.label))
        }
    }
    static var previews: some View {
        Preview(model: ZoomMenuModel(webView: WKWebView()))
    }
}
