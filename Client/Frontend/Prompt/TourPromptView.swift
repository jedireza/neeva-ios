// Copyright Neeva. All rights reserved.

import SwiftUI

struct TourPromptView: View {
    var onConfirm: (()-> Void)?
    let title: String
    let description: String
    let buttonMessage: String

    init(title: String, description: String, buttonMessage: String, onConfirm: (()-> Void)? = nil) {
        self.onConfirm = onConfirm
        self.title = title
        self.description = description
        self.buttonMessage = buttonMessage
    }

    var body: some View {
        ZStack {
            Color.Neeva.Tour.Background
            ScrollView {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(Color.Neeva.Tour.Title)
                        .font(.headline)
                        .padding(.bottom, 8)
                    Text(description)
                        .foregroundColor(Color.Neeva.Tour.Description)
                        .font(.callout)
                }
                .fixedSize(horizontal: false, vertical: true)
                Button(action: onConfirm!) {
                    ZStack {
                        Color.Neeva.Tour.ButtonBackground
                        Text(buttonMessage)
                            .foregroundColor(Color.Neeva.Tour.ButtonText)
                            .font(.system(size: 16, weight: .bold))

                    }
                }
                .cornerRadius(30)
                .frame(height: 40)
                .padding(.horizontal, 6)
            }
            .padding([.leading, .trailing, .top], NeevaUIConstants.menuOuterPadding)
        }
    }
}

struct TourPromptView_Previews: PreviewProvider {
    static var previews: some View {
        TourPromptView(title: "Test title", description: "Test description", buttonMessage: "Got it!")
    }
}
