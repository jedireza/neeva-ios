// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import WebKit

struct ZoomMenuView: View {
    @ObservedObject var model: ZoomMenuModel
    let onDismiss: () -> ()

    private let cellHeight = CGFloat(52)
    private struct Cell<Content: View>: View {
        let content: () -> Content
        var body: some View {
            content()
                .background(Color.background)
                .cornerRadius(12)
        }
    }
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onDismiss) {
                Color.clear
                    .frame(maxHeight: .infinity)
            }.accessibilityHidden(true)

            VStack(spacing: 12) {
                Cell {
                    HStack {
                        Button(action: model.zoomOut) {
                            Symbol(.minus, style: .bodyLarge)
                                .frame(width: cellHeight, height: cellHeight)
                                .foregroundColor(model.canZoomOut ? .label : .tertiaryLabel)
                        }.disabled(!model.canZoomOut)
                        Spacer()
                        Symbol(.textformatSize, style: .headingLarge)
                        Spacer()
                        Button(action: model.zoomIn) {
                            Symbol(.plus, style: .bodyLarge)
                                .frame(width: cellHeight, height: cellHeight)
                                .foregroundColor(model.canZoomIn ? .label : .tertiaryLabel)
                        }.disabled(!model.canZoomIn)
                    }.frame(height: cellHeight)
                }
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

                Cell {
                    Button(action: { model.pageZoom = 1 }) {
                        HStack {
                            Spacer()
                            Text("Reset").withFont(.bodyLarge)
                            Spacer()
                        }.frame(height: cellHeight)
                    }.foregroundColor(.red)
                }

                Cell {
                    Button(action: onDismiss) {
                        HStack {
                            Spacer()
                            Text("Done").withFont(.labelLarge)
                            Spacer()
                        }.frame(height: cellHeight)
                    }.foregroundColor(.ui.adaptive.blue)
                }
            }
            .buttonStyle(TableCellButtonStyle())
            .padding(16)
            .background(
                Color.groupedBackground
                    .cornerRadius(12, corners: .top)
                    .ignoresSafeArea()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.12))
                            .blur(radius: 16)
                            .offset(y: 4)
                    )
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
