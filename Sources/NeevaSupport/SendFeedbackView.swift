//
//  SendFeedbackView.swift
//  
//
//  Created by Jed Fox on 1/7/21.
//

import SwiftUI

public struct SendFeedbackView: View {
    let canShareResults: Bool
    let requestId: String?
    let geoLocationStatus: String?

    let onDismiss: (() -> ())?

    public init(onDismiss: (() -> ())? = nil, canShareResults: Bool = false, requestId: String? = nil, geoLocationStatus: String? = nil) {
        self.canShareResults = canShareResults
        self.requestId = requestId
        self.geoLocationStatus = geoLocationStatus
        self.onDismiss = onDismiss
    }

    @Environment(\.presentationMode) var presentationMode

    @State var feedbackText = ""
    @State var shareResults = true
    @State var isSending = false

    public var body: some View {
        NavigationView {
            Form {
                DecorativeSection {
                    MultilineTextField("Please type your feedback here", text: $feedbackText)
                }
                if canShareResults {
                    DecorativeSection {
                        Toggle("Share my query to help improve Neeva.", isOn: $shareResults)
                    }
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss ?? { presentationMode.wrappedValue.dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSending {
                        ActivityIndicator()
                    } else {
                        Button("Send") {
                            isSending = true
                            SendFeedbackMutation(
                                input: .init(
                                    feedback: feedbackText,
                                    shareResults: canShareResults && shareResults,
                                    requestId: requestId,
                                    geoLocationStatus: geoLocationStatus,
                                    source: .app
                                )
                            ).perform { result in
                                isSending = false
                                switch result {
                                case .success:
                                    if let onDismiss = onDismiss {
                                        onDismiss()
                                    } else {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                        .disabled(feedbackText.isEmpty)
                    }
                }
            }
        }.presentation(isModal: !feedbackText.isEmpty)
    }
}

struct AddToSpaceDemoView_Previews: PreviewProvider {
    struct TestView: View {
        @State var open = true
        var body: some View {
            Button("Press \(Image(systemName: "arrowtriangle.right.circle")) above to interact with this preview") { open = true }
                .sheet(isPresented: $open) {
                    SendFeedbackView()
                }
        }
    }
    static var previews: some View {
        SendFeedbackView()
        SendFeedbackView(canShareResults: true)
        TestView()
    }
}
