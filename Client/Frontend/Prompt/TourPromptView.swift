// Copyright Neeva. All rights reserved.

import SwiftUI

fileprivate struct CloseButton: View {
    var onClose: (()-> Void)

    var body: some View {
        Button(action: onClose) {
            ZStack(alignment: .center) {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 40, height: 40, alignment: .center)
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(Color.Tour.Title)
            }
        }
        .accessibilityLabel("Dismiss tour")
    }
}

struct TourPromptView: View {
    var onConfirm: (()-> Void)?
    let title: String
    let description: String
    let buttonMessage: String?
    var onClose: (()-> Void)?
    let staticColorMode: Bool
    @Environment(\.colorScheme) private var colorScheme

    init(title: String, description: String, buttonMessage: String? = nil, onConfirm: (()-> Void)? = nil, onClose: (()-> Void)? = nil, staticColorMode: Bool = false) {
        self.onConfirm = onConfirm
        self.title = title
        self.description = description
        self.buttonMessage = buttonMessage
        self.onClose = onClose
        self.staticColorMode = staticColorMode
    }

    var body: some View {
        ZStack {
            Color.Tour.Background
            ScrollView {
                HStack(alignment:.top) {
                    VStack {
                        VStack(alignment: .leading) {
                            Text(title)
                                .foregroundColor(Color.Tour.Title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.bottom, 8)
                            Text(description)
                                .foregroundColor(Color.Tour.Description)
                                .font(.system(size: 14))
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        if let buttonMessage = buttonMessage, let onConfirm = onConfirm, !buttonMessage.isEmpty {
                            Button(action: onConfirm) {
                                ZStack {
                                    Color.Tour.ButtonBackground
                                    Text(buttonMessage)
                                        .foregroundColor(Color.Tour.ButtonText)
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .cornerRadius(30)
                            .frame(height: 40)
                            .padding(.horizontal, 6)
                        }
                    }
                    if onClose != nil {
                        Spacer()
                        CloseButton(onClose: onClose!)
                    }
                }
            }
            .padding([.leading, .trailing, .top], NeevaUIConstants.menuOuterPadding)
        }
        .colorScheme(staticColorMode ? .light : colorScheme)
    }
}

struct TourPromptView_Previews: PreviewProvider {
    static var previews: some View {
        TourPromptView(title: "Test title", description: "Test description", buttonMessage: "Got it!")
    }
}
