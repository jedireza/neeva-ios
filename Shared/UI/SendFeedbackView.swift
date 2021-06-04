// Copyright Neeva. All rights reserved.

import SwiftUI
import QuickLook

/// Ask the user for feedback
public struct SendFeedbackView: View {
    let canShareResults: Bool
    let requestId: String?
    let geoLocationStatus: String?
    let initialText: String
    let onDismiss: (() -> ())?
    let screenshot: UIImage?

    /// - Parameters:
    ///   - screenshot: A screenshot image that the user may optionally send along with the text
    ///   - onDismiss: If provided, this will be called when the user wants to dismiss the feedback screen. Useful when presenting from UIKit, where `presentationMode.wrappedValue.dismiss()` has no effect
    ///   - canShareResults: if `true`, display a “Share my query to help improve Neeva” toggle
    ///   - requestId: A request ID to send along with the user-provided feedback
    ///   - geoLocationStatus: passed along to the API
    ///   - initialText: Text to pre-fill the feedback input with. If non-empty, the user can submit feedback without entering any additional text.
    public init(screenshot: UIImage?, onDismiss: (() -> ())? = nil, canShareResults: Bool = false, requestId: String? = nil, geoLocationStatus: String? = nil, initialText: String = "") {
        self.screenshot = screenshot
        self.canShareResults = canShareResults
        self.requestId = requestId
        self.geoLocationStatus = geoLocationStatus
        self.onDismiss = onDismiss
        self._feedbackText = .init(initialValue: initialText)
        self.initialText = initialText
        self._editedScreenshot = .init(initialValue: screenshot ?? UIImage())
    }

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onOpenURL) var onOpenURL

    @State var feedbackText = ""
    @State var shareResults = true
    @State var shareScreenshot = true
    @State var isSending = false
    @State var screenshotSheet = ModalState()
    @State var editedScreenshot: UIImage

    public var body: some View {
        NavigationView {
            Form {
                Section(
                    header: HStack {
                        VStack(alignment: .leading) {
                            Text("Need help or want instant answers to FAQs?")
                                .foregroundColor(.primary)
                            Button(action: { onOpenURL(NeevaConstants.appFAQURL) }) {
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
                if let screenshot = screenshot, FeatureFlag[.feedbackScreenshot] {
                    DecorativeSection {
                        Toggle(isOn: $shareScreenshot) {
                            VStack(alignment: .leading) {
                                Text("Share Screenshot").bold()
                                Button("View or edit") { screenshotSheet.present() }
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(!shareScreenshot)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(.vertical, 4)
                        .padding(.leading, -4)
                        .modal(state: $screenshotSheet) {
                            QuickLookView(image: $editedScreenshot, original: screenshot)
                        }
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
        }
        .presentation(isModal: feedbackText != initialText)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension UIImage {
    // https://stackoverflow.com/a/33675160/5244995
    convenience init?(color: UIColor, width: CGFloat, height: CGFloat) {
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

struct SendFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        // iPhone 12 screen size
        SendFeedbackView(screenshot: UIImage(color: .systemRed, width: 390, height: 844)!)
        // iPhone 8 screen size
        SendFeedbackView(screenshot: UIImage(color: .systemRed, width: 375, height: 667)!)
        SendFeedbackView(screenshot: UIImage(color: .systemBlue, width: 390, height: 844)!, canShareResults: true)
    }
}
