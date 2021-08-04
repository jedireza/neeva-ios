// Copyright Neeva. All rights reserved.

import SwiftUI
import UIKit

protocol ToastViewDelegate: AnyObject {
    func dismiss()
    func draggingUpdated()
    func draggingEnded(dismissing: Bool)
}

public enum ToastViewUX {
    static let defaultDisplayTime = 4.5
    static let height: CGFloat = 53
    static let threshold: CGFloat = 15
    static let ToastDefaultColor = UIColor.Photon.Grey60
}

struct ToastStateContent {
    var text: String?
    var buttonText: String?
    var buttonAction: (() -> Void)?
}

class ToastViewContent: ObservableObject {
    @Published var currentToastStateContent: ToastStateContent

    func updateStatus(with status: ToastProgressStatus) {
        switch status {
        case .inProgress:
            currentToastStateContent = normalContent
        case .success:
            if let completedContent = completedContent {
                currentToastStateContent = completedContent
            }
        case .failed:
            if let failedContent = failedContent {
                currentToastStateContent = failedContent
            }
        }
    }

    var normalContent: ToastStateContent
    var completedContent: ToastStateContent?
    var failedContent: ToastStateContent?

    init(
        normalContent: ToastStateContent, completedContent: ToastStateContent? = nil,
        failedContent: ToastStateContent? = nil
    ) {
        self.currentToastStateContent = normalContent

        self.normalContent = normalContent
        self.completedContent = completedContent
        self.failedContent = failedContent
    }
}

struct ToastView: View {
    /// used by ToastViewModel to dismiss view
    weak var viewDelegate: ToastViewDelegate?

    // how long the Toast is shown
    var displayTime = ToastViewUX.defaultDisplayTime
    var autoDismiss = true

    // content
    @ObservedObject var content: ToastViewContent
    var toastProgressViewModel: ToastProgressViewModel?

    @State var offset: CGFloat = 0
    var opacity: CGFloat {
        let delta = abs(offset) - ToastViewUX.threshold
        return delta > 0 ? 1 - delta / (ToastViewUX.threshold * 3) : 1
    }

    var drag: some Gesture {
        DragGesture()
            .onChanged {
                self.offset = $0.translation.height
                viewDelegate?.draggingUpdated()
            }
            .onEnded {
                var dismissing = false
                if abs($0.predictedEndTranslation.height) > ToastViewUX.height * 1.5 {
                    self.offset = $0.predictedEndTranslation.height
                    dismissing = true
                } else if abs($0.translation.height) > ToastViewUX.height {
                    dismissing = true
                } else {
                    self.offset = 0
                }

                viewDelegate?.draggingEnded(dismissing: dismissing)
            }
    }

    var body: some View {
        VStack {
            Spacer()

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color(ToastViewUX.ToastDefaultColor))
                    .shadow(
                        color: Color(red: 0, green: 0, blue: 0, opacity: 0.40), radius: 48, x: 0,
                        y: 16
                    )
                    .frame(minHeight: ToastViewUX.height)

                HStack(spacing: 16) {
                    if let toastProgressViewModel = toastProgressViewModel {
                        ToastProgressView { _ in
                            content.updateStatus(with: toastProgressViewModel.status)

                            if toastProgressViewModel.status == .success {
                                Timer.scheduledTimer(
                                    withTimeInterval: displayTime, repeats: false,
                                    block: { _ in
                                        viewDelegate?.dismiss()
                                    })
                            }
                        }
                        .environmentObject(toastProgressViewModel)
                    }

                    Text(content.currentToastStateContent.text ?? "")
                        .withFont(.bodyMedium)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical)

                    if let buttonText = content.currentToastStateContent.buttonText {
                        Spacer()

                        Button(
                            action: {
                                if let buttonAction = content.currentToastStateContent.buttonAction
                                {
                                    buttonAction()
                                }

                                viewDelegate?.dismiss()
                            },
                            label: {
                                Text(buttonText)
                                    .withFont(.labelLarge)
                                    .foregroundColor(Color.ui.aqua)

                            })
                    }
                }.padding(.horizontal, 16).colorScheme(.dark)
            }.frame(height: 53).padding(.horizontal)
        }
        .offset(y: offset)
        .gesture(drag)
        .opacity(Double(opacity))
        .animation(.interactiveSpring(), value: offset)
        .onAppear {
            if let toastProgressViewModel = toastProgressViewModel {
                content.updateStatus(with: toastProgressViewModel.status)
            }
        }
    }

    public func enqueue(at location: ToastQueueLocation = .last) {
        ToastViewManager.shared.enqueue(toast: self, at: location)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(
            content: ToastViewContent(
                normalContent: ToastStateContent(text: "Tab Closed", buttonText: "restore")))
    }
}
