// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct PopoverView<Content: View>: View {
    @State private var title: LocalizedStringKey? = nil

    let style: OverlayStyle
    let onDismiss: () -> Void
    let content: () -> Content

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // The semi-transparent backdrop used to shade the content that lies below
                // the sheet.
                Button(action: style.nonDismissible ? {} : onDismiss) {
                    Color.black
                        .opacity(0.2)
                        .ignoresSafeArea()
                }
                .buttonStyle(HighlightlessButtonStyle())
                .accessibilityHint("Dismiss pop-up window")
                // make this the last option. This will bring the user’s focus first to the
                // useful content inside of the overlay sheet rather than the close button.
                .accessibilitySortPriority(-1)

                VStack {
                    if style.showTitle, let title = title {
                        HStack(spacing: 0) {
                            Text(title)
                                .withFont(.headingXLarge)
                                .foregroundColor(.label)
                                .padding(.leading, 16)

                            Spacer()

                            Button(action: onDismiss) {
                                Symbol(.xmark, style: .headingXLarge, label: "Close")
                                    .foregroundColor(.tertiaryLabel)
                                    .tapTargetFrame()
                                    .padding(.trailing, 4.5)
                            }
                        }
                    }

                    content()
                        .onPreferenceChange(OverlayTitlePreferenceKey.self) { self.title = $0 }
                }
                .frame(width: geo.size.width / 1.5)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    Color(style.backgroundColor)
                        .cornerRadius(16)
                )
                .padding()
            }
            .accessibilityAction(.escape, onDismiss)
        }
    }
}
