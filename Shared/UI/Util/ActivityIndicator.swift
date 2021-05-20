// Copyright Neeva. All rights reserved.

import SwiftUI

/// An activity indicator (spinner/throbber) view
struct ActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style
    let isAnimating: Bool

    /// - Parameters:
    ///   - style: the size of spinner to display
    ///   - isAnimating: if `false`, the spinner will appear frozen
    init(style: UIActivityIndicatorView.Style = .medium, isAnimating: Bool = true) {
        self.style = style
        self.isAnimating = isAnimating
    }

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }
    func updateUIView(_ indicator: UIActivityIndicatorView, context: Context) {
        indicator.hidesWhenStopped = false
        indicator.style = style
        if isAnimating && !indicator.isAnimating {
            indicator.startAnimating()
        } else if !isAnimating && indicator.isAnimating {
            indicator.stopAnimating()
        }
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActivityIndicator()
            ActivityIndicator(style: .large)
            ActivityIndicator(isAnimating: false)
        }.padding().previewLayout(.sizeThatFits)
    }
}
