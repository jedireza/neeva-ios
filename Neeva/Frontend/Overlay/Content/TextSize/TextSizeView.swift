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
                TextSizeStepper(model: model)
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
