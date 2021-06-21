// Copyright Neeva. All rights reserved.

import SwiftUI
import QuickLook

/// Ask the user for feedback
public struct SendFeedbackView: View {
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
    public init(screenshot: UIImage?, url: URL?, onDismiss: (() -> ())? = nil, requestId: String? = nil, geoLocationStatus: String? = nil, initialText: String = "") {
        self.screenshot = screenshot
        self._url = .init(initialValue: url)
        self.requestId = requestId
        self.geoLocationStatus = geoLocationStatus
        self.onDismiss = onDismiss
        self._feedbackText = .init(initialValue: initialText)
        self.initialText = initialText
        self._editedScreenshot = .init(initialValue: screenshot ?? UIImage())
    }

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onOpenURL) var onOpenURL

    @State var url: URL?
    @State var feedbackText = ""
    @State var shareURL = true
    @State var isEditingURL = false
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
                                .foregroundColor(.label)
                            Button(action: {
                                onOpenURL(NeevaConstants.appFAQURL)
                                if let onDismiss = onDismiss {
                                    onDismiss()
                                }
                            }) {
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
                        .if(shouldHighlightTextInput()) { view in
                            view
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.neeva.brand.blue, lineWidth: 4)
                                        .padding(.horizontal, -10))
                        }
                }

                if let screenshot = screenshot, FeatureFlag[.feedbackScreenshot] {
                    DecorativeSection {
                        Toggle(isOn: $shareScreenshot) {
                            VStack(alignment: .leading) {
                                Text("Share Screenshot").bold()
                                Button("View or edit") { screenshotSheet.present() }
                                    .disabled(!shareScreenshot)
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.leading, -4)
                        .modal(state: $screenshotSheet) {
                            QuickLookView(image: $editedScreenshot, original: screenshot)
                        }
                    }
                }
                if let url = url {
                    DecorativeSection {
                        Toggle(isOn: $shareURL) {
                            VStack(alignment: .leading) {
                                Text("Share URL")
                                    .bold()
                                HStack {
                                    let displayURL: String = {
                                        let display = url.absoluteDisplayString
                                        if display.hasPrefix("https://") {
                                            return String(display[display.index(display.startIndex, offsetBy: "https://".count)...])
                                        }
                                        return display
                                    }()
                                    Text(displayURL)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    Button("edit") { isEditingURL = true }
                                        .background(
                                            NavigationLink(
                                                destination: EditURLView($url, isActive: $isEditingURL),
                                                isActive: $isEditingURL
                                            ) { EmptyView() }
                                            .hidden()
                                        )
                                        .disabled(!shareURL)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.leading, -4)
                    }
                }
            }
            .applyToggleStyle()
            .navigationTitle("Back")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Send Feedback").font(.headline)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss ?? { presentationMode.wrappedValue.dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSending {
                        ActivityIndicator()
                    } else {
                        Button("Send") {
                            isSending = true
                            let feedbackText: String
                            if let url = url, shareURL {
                                feedbackText = self.feedbackText + "\n\nCurrent URL: \(url.absoluteString)"
                            } else {
                                feedbackText = self.feedbackText
                            }
                            SendFeedbackMutation(
                                input: .init(
                                    feedback: feedbackText,
                                    shareResults: false,
                                    requestId: requestId,
                                    geoLocationStatus: geoLocationStatus,
                                    source: .app
                                )
                            ).perform { result in
                                isSending = false
                                switch result {
                                case .success:
                                    updateTourManagerUponSuccess()
                                    if let onDismiss = onDismiss {
                                        onDismiss()
                                    } else {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                                TourManager.shared.reset()
                            }
                        }
                        .disabled(feedbackText.isEmpty)
                    }
                }
            }
        }
        .presentation(isModal: feedbackText != initialText || isEditingURL)
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear(perform: viewDidDisappear)
    }

    struct EditURLView: View {
        init(_ url: Binding<URL?>, isActive: Binding<Bool>) {
            _isActive = isActive
            _url = url
            self._urlString = .init(wrappedValue: url.wrappedValue?.absoluteString ?? "")
        }

        @Binding private var isActive: Bool
        @Binding private var url: URL?
        @State private var urlString: String

        var body: some View {
            Form {
                DecorativeSection {
                    MultilineTextField(
                        "Enter a URL to submit with the feedback",
                        text: $urlString,
                        onCommit: { isActive = false },
                        customize: { tf in
                            tf.keyboardType = .URL
                            tf.autocapitalizationType = .none
                            tf.autocorrectionType = .no
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                tf.becomeFirstResponder()
                            }
                        }
                    )
                    .onChange(of: urlString) { value in
                        self.url = URL(string: urlString)
                    }
                }
            }
            .navigationTitle("Edit URL")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isActive = false }
                }
            }
        }
    }

    private func viewDidDisappear() {
        TourManager.shared.notifyCurrentViewClose()
    }

    private func updateTourManagerUponSuccess() {
        TourManager.shared.userReachedStep(step: .promptFeedbackInNeevaMenu)
        TourManager.shared.userReachedStep(step: .openFeedbackPanelWithInputFieldHighlight)
    }

    private func shouldHighlightTextInput() -> Bool {
        return TourManager.shared.isCurrentStep(with: .promptFeedbackInNeevaMenu) || TourManager.shared.isCurrentStep(with: .openFeedbackPanelWithInputFieldHighlight)
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
        SendFeedbackView(screenshot: UIImage(color: .systemRed, width: 390, height: 844)!, url: URL(string: "https://neeva.com/search?q=abcdef+ghijklmnop"))
        // iPhone 8 screen size
        SendFeedbackView(screenshot: UIImage(color: .systemRed, width: 375, height: 667)!, url: NeevaConstants.appURL)
        SendFeedbackView(screenshot: UIImage(color: .systemBlue, width: 390, height: 844)!, url: NeevaConstants.appURL)
    }
}
