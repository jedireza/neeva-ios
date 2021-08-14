// Copyright Neeva. All rights reserved.

import QuickLook
import SwiftUI

/// Ask the user for feedback
public struct SendFeedbackView: View {
    let requestId: String?
    let geoLocationStatus: String?
    let initialText: String
    let onDismiss: (() -> Void)?
    let screenshot: UIImage?
    let query: String?

    /// - Parameters:
    ///   - screenshot: A screenshot image that the user may optionally send along with the text
    ///   - onDismiss: If provided, this will be called when the user wants to dismiss the feedback screen. Useful when presenting from UIKit, where `presentationMode.wrappedValue.dismiss()` has no effect
    ///   - canShareResults: if `true`, display a “Share my query to help improve Neeva” toggle
    ///   - requestId: A request ID to send along with the user-provided feedback
    ///   - geoLocationStatus: passed along to the API
    ///   - initialText: Text to pre-fill the feedback input with. If non-empty, the user can submit feedback without entering any additional text.
    public init(
        screenshot: UIImage?, url: URL?, onDismiss: (() -> Void)? = nil, requestId: String? = nil,
        query: String? = nil, geoLocationStatus: String? = nil, initialText: String = ""
    ) {
        self.screenshot = screenshot
        self._url = .init(initialValue: url)
        self.requestId = requestId
        self.geoLocationStatus = geoLocationStatus
        self.onDismiss = onDismiss
        self._feedbackText = .init(initialValue: initialText)
        self.initialText = initialText
        self._editedScreenshot = .init(initialValue: screenshot ?? UIImage())
        self.query = query
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
    @State var shareQuery = true
    @State var focusedTextField = false

    public var body: some View {
        NavigationView {
            ScrollView {
                GroupedStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Need help or want instant answers to FAQs?")
                                .withFont(.bodyLarge)
                                .foregroundColor(.label)
                            Button(action: {
                                onOpenURL(NeevaConstants.appFAQURL)
                                if let onDismiss = onDismiss {
                                    onDismiss()
                                }
                            }) {
                                Text("Visit our Help Center!").underline()
                                    .withFont(.bodyLarge)
                            }
                        }
                        .font(.body)
                        Spacer()
                    }

                    GroupedCell {
                        MultilineTextField(
                            "Please share your questions, issues, or feature requests. Your feedback helps us improve Neeva!",
                            text: $feedbackText,
                            customize: { tf in
                                if !focusedTextField {
                                    // Disabled for now due to issue #1400. This prevents interaction
                                    // with the web page after submitting feedback.
                                    //tf.becomeFirstResponder()
                                    focusedTextField = true
                                }
                            }
                        ).padding(.vertical, 7)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brand.blue, lineWidth: 4)
                            .padding(.horizontal, -10)
                            .opacity(shouldHighlightTextInput ? 1 : 0)
                    )
                    .padding(.vertical, 12)

                    VStack(spacing: 8) {
                        if let screenshot = screenshot, NeevaFeatureFlags[.feedbackScreenshot] {
                            GroupedCell {
                                Toggle(isOn: $shareScreenshot) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Share Screenshot")
                                            .withFont(.labelLarge)
                                        Button(action: { screenshotSheet.present() }) {
                                            Text("View or edit").withFont(.labelMedium)
                                        }
                                        .disabled(!shareScreenshot)
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .padding(.vertical, 9)
                                .modal(state: $screenshotSheet) {
                                    QuickLookView(image: $editedScreenshot, original: screenshot)
                                }
                                .accessibilityAction(named: "View or Edit Screenshot") {
                                    screenshotSheet.present()
                                }
                            }
                        }

                        if let query = query, requestId != nil, NeevaFeatureFlags[.feedbackQuery] {
                            GroupedCell {
                                Toggle(isOn: $shareQuery) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Share My Search")
                                            .withFont(.labelLarge)
                                        Text("“\(query)”")
                                            .withFont(.labelMedium)
                                            .foregroundColor(.secondaryLabel)
                                            .lineLimit(1)
                                    }
                                }.padding(.vertical, 9)
                            }
                        } else if let url = url {
                            GroupedCell {
                                Toggle(isOn: $shareURL) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Share URL").bold().withFont(.labelLarge)
                                        HStack {
                                            let displayURL: String = {
                                                let display = url.absoluteDisplayString
                                                if display.hasPrefix("https://") {
                                                    return String(
                                                        display[
                                                            display.index(
                                                                display.startIndex,
                                                                offsetBy: "https://".count)...])
                                                }
                                                return display
                                            }()
                                            Text(displayURL)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                            Button(action: { isEditingURL = true }) {
                                                Text("edit").withFont(.labelMedium)
                                            }
                                            .background(
                                                NavigationLink(
                                                    destination: EditURLView(
                                                        $url, isActive: $isEditingURL),
                                                    isActive: $isEditingURL
                                                ) { EmptyView() }
                                                .hidden()
                                            )
                                            .disabled(!shareURL)
                                            .padding(.trailing, 8)
                                        }
                                    }
                                }
                                .padding(.vertical, 9)
                                .accessibilityAction(named: "Edit URL") { isEditingURL = true }
                            }
                        }
                    }
                    Spacer()
                }
            }
            .background(Color.groupedBackground.ignoresSafeArea())
            .applyToggleStyle()
            .navigationTitle("Back")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Send Feedback").font(.headline)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        "Cancel", action: onDismiss ?? { presentationMode.wrappedValue.dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSending {
                        ActivityIndicator()
                    } else {
                        Button("Send", action: sendFeedbackHandler)
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                tf.becomeFirstResponder()
                            }
                        }
                    )
                    .padding(.horizontal, -10)
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

    private var shouldHighlightTextInput: Bool {
        return TourManager.shared.isCurrentStep(with: .promptFeedbackInNeevaMenu)
            || TourManager.shared.isCurrentStep(with: .openFeedbackPanelWithInputFieldHighlight)
    }

    private func sendFeedbackHandler() {
        isSending = true
        let feedbackText: String

        if let url = url, shareURL,
            query == nil || requestId == nil || !NeevaFeatureFlags[.feedbackQuery]
        {
            feedbackText = self.feedbackText + "\n\nCurrent URL: \(url.absoluteString)"
        } else {
            feedbackText = self.feedbackText
        }

        let shareResults = NeevaFeatureFlags[.feedbackQuery] ? shareQuery && query != nil : false

        SendFeedbackMutation(
            input: .init(
                feedback: feedbackText,
                shareResults: shareResults,
                requestId: (requestId?.isEmpty ?? true) ? nil : requestId,
                geoLocationStatus: geoLocationStatus,
                source: .app,
                screenshot: shareScreenshot && NeevaFeatureFlags[.feedbackScreenshot]
                    ? editedScreenshot.reduceAndConvertToBase64(maxSize: 800) : nil
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
}

extension UIImage {
    // https://stackoverflow.com/a/33675160/5244995
    fileprivate convenience init?(color: UIColor, width: CGFloat, height: CGFloat) {
        let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    // Reduce size and convert image to base64 string format
    fileprivate func reduceAndConvertToBase64(maxSize: CGFloat) -> String? {
        let resizedImage = self.resize(maxSize)
        let imageData = resizedImage.pngData()
        return imageData?.base64EncodedString()
    }
}

struct SendFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        // iPhone 12 screen size
        SendFeedbackView(
            screenshot: UIImage(color: .systemRed, width: 390, height: 844)!,
            url: nil, requestId: "swiftui-preview", query: "Best Air Purifier")
        // iPhone 8 screen size
        SendFeedbackView(
            screenshot: UIImage(color: .systemRed, width: 375, height: 667)!,
            url: "https://www.amazon.com/dp/B0863TXG")
        SendFeedbackView(
            screenshot: UIImage(color: .systemBlue, width: 390, height: 844)!,
            url: "https://www.amazon.com/dp/B0863TXG",
            initialText: Array(repeating: "Placeholder text for filled form.", count: 5).joined(
                separator: "\n"))
    }
}
