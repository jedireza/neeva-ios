// Copyright Neeva. All rights reserved.

import SwiftUI

/// Ask the user for feedback
public struct SendFeedbackView: View {
    let canShareResults: Bool
    let requestId: String?
    let geoLocationStatus: String?
    let initialText: String
    let onDismiss: (() -> ())?

    /// - Parameters:
    ///   - onDismiss: If provided, this will be called when the user wants to dismiss the feedback screen. Useful when presenting from UIKit, where `presentationMode.wrappedValue.dismiss()` has no effect
    ///   - canShareResults: if `true`, display a “Share my query to help improve Neeva” toggle
    ///   - requestId: A request ID to send along with the user-provided feedback
    ///   - geoLocationStatus: passed along to the API
    ///   - initialText: Text to pre-fill the feedback input with. If non-empty, the user can submit feedback without entering any additional text.
    public init(onDismiss: (() -> ())? = nil, canShareResults: Bool = false, requestId: String? = nil, geoLocationStatus: String? = nil, initialText: String = "") {
        self.canShareResults = canShareResults
        self.requestId = requestId
        self.geoLocationStatus = geoLocationStatus
        self.onDismiss = onDismiss
        self._feedbackText = .init(initialValue: initialText)
        self.initialText = initialText
    }

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onOpenURL) var onOpenURL

    @State var feedbackText = ""
    @State var shareResults = true
    @State var isSending = false

    public var body: some View {
        NavigationView {
            Form {
                Section(
                    header: HStack {
                        VStack(alignment: .leading) {
                            Text("Need help or want instant answers to FAQs?")
                                .foregroundColor(.primary)
                            SwiftUI.Button(action: { onOpenURL(NeevaConstants.appFAQURL) }) {
                                Text("Visit our Help Center!").underline()
                            }
                        }
                        .font(.body)
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                    .textCase(nil)
                ) {
                    MultilineTextField("Please share your questions, issues, or feature requests. Your feedback helps us improve Neeva!", text: $feedbackText)
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
                    SwiftUI.Button("Cancel", action: onDismiss ?? { presentationMode.wrappedValue.dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSending {
                        ActivityIndicator()
                    } else {
                        SwiftUI.Button("Send") {
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
        }.presentation(isModal: feedbackText != initialText)
    }
}

extension SendFeedbackView {
    /// A button that will present the “Send Feedback” view as a sheet when tapped.
    public struct Button: View {
        @Environment(\.font) private var font
        @State private var presenting = false

        private let sheet: SendFeedbackView
        /// Parameters are the same as those passed to `SendFeedbackView`
        public init(onDismiss: (() -> ())? = nil, canShareResults: Bool = false, requestId: String? = nil, geoLocationStatus: String? = nil, initialText: String = "") {
            sheet = SendFeedbackView(onDismiss: onDismiss, canShareResults: canShareResults, requestId: requestId, geoLocationStatus: geoLocationStatus, initialText: initialText)
        }

        public var body: some View {
            SwiftUI.Button(action: { presenting = true }) {
                Label("Send Feedback", systemImage: "bubble.left.fill")
                    .font(font?.bold())
            }.sheet(isPresented: $presenting) {
                sheet.font(.body)
            }
        }
    }
}

struct SendFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        SendFeedbackView()
        SendFeedbackView(canShareResults: true)
        SendFeedbackView.Button()
        SendFeedbackView.Button().font(.largeTitle)
    }
}
