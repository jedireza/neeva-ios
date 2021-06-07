// Copyright Neeva. All rights reserved.

import SwiftUI

/// A view that displays a loading indicator with an associated label.
/// Use a mini `LoadingView` when part of a screen is loading, and a regular one when an entire screen is loading.
/// Regular-sized `LoadingView`s only appear after a short delay to reduce flashing if data loads quickly.
public struct LoadingView: View {
    let label: Text
    let mini: Bool
    @State var opacity = 0.0

    /// - Parameters:
    ///   - label: The text to display below or beside the activity indicator
    ///   - mini: If `true`, a smaller activity indicator is rendered, and the text is displayed next to the indicator instead of below it.
    public init(_ label: String, mini: Bool = false) {
        self.label = Text(label)
        self.mini = mini
    }
    /// - Parameters:
    ///   - label: The text to display below or beside the activity indicator
    ///   - mini: If `true`, a smaller activity indicator is rendered, and the text is displayed next to the indicator instead of below it.
    public init(_ label: Text, mini: Bool = false) {
        self.label = label
        self.mini = mini
    }

    public var body: some View {
        if mini {
            HStack {
                ActivityIndicator(style: .medium)
                label
                    .padding(.leading)
                    .padding(.vertical, 5)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondaryLabel)
            }
        } else {
            HStack {
                Spacer()
                VStack {
                    ActivityIndicator(style: .large)
                    label
                        .font(Font.title2.bold())
                        .padding(.top)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                .opacity(opacity)
                .onAppear {
                    DispatchQueue.main.async {
                        withAnimation(
                            Animation.easeIn
                                .delay(0.3)
                        ) { opacity = 1 }
                    }
                }
                Spacer()
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section {
                LoadingView("Adding to space…", mini: true)
            }
            Section {
                LoadingView(String(repeating: "A really long title, ", count: 10), mini: true)
            }
        }
        LoadingView("Adding to space…")
        LoadingView(String(repeating: "A really long title, ", count: 10))
        LoadingView(String(repeating: "A really long title, ", count: 10))
            .previewDevice("iPod touch (7th generation)")
    }
}
