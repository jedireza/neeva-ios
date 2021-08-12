// Copyright Neeva. All rights reserved.

import SwiftUI

/// This button style updates a binding to reflect its pressed state.
/// You are responsible for making the pressed state visible since the button will no longer change its appearance.
struct PressReportingButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    var animation: Animation? = .interactiveSpring()

    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed) { value in
                withAnimation(animation) {
                    isPressed = value
                }
            }
    }
}

struct PressReportingButtonStyle_Previews: PreviewProvider {
    struct Preview: View {
        @State var isPressed = false

        var body: some View {
            VStack(spacing: 30) {
                Label("Pressed?", systemSymbol: isPressed ? .checkmarkSquare : .square)

                Button("Press Here!") {}
                    .padding()
                    .background(Capsule().fill(Color.systemFill))
                    .buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
            }
            .padding()
        }
    }
    static var previews: some View {
        Preview()
            .previewLayout(.sizeThatFits)
    }
}
