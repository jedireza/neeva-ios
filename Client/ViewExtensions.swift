// Copyright Neeva. All rights reserved.

import SwiftUI

struct ThrobbingHighlightBorder: ViewModifier {
    // animation effect
    @State var isAtMaxScale = false
    private let animation = Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
    var highlight: Color = Color.blue

    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(highlight, lineWidth: 4)
                    .opacity(Double(2 - (isAtMaxScale ? 1.5 : 1.0)))
                    .scaleEffect(isAtMaxScale ? 1.05 : 1.0)
                    .onAppear {
                        withAnimation(
                            self.animation,
                            {
                                self.isAtMaxScale.toggle()
                            })
                    }
            )
    }
}

extension View {
    public func throbbingHighlightBorderStyle(highlight: Color) -> some View {
        self.modifier(ThrobbingHighlightBorder(highlight: highlight))
    }
}
