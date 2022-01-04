// Copyright Neeva. All rights reserved.

import SwiftUI
import UIKit

public enum ToastViewUX {
    static let defaultDisplayTime = 4.5
    static let height: CGFloat = 53
    static let threshold: CGFloat = 15
    static let ToastDefaultColor = UIColor.Photon.Grey60
}

struct ToastStateContent {
    var text: LocalizedStringKey?
    var buttonText: LocalizedStringKey?
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
    weak var viewDelegate: BannerViewDelegate?

    // how long the Toast is shown
    var displayTime = ToastViewUX.defaultDisplayTime
    var autoDismiss = true

    // content
    @ObservedObject var content: ToastViewContent
    var toastProgressViewModel: ToastProgressViewModel?

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
        .modifier(
            DraggableBannerModifier(
                draggingUpdated: viewDelegate?.draggingUpdated,
                draggingEnded: viewDelegate?.draggingEnded(dismissing:))
        )
        .onAppear {
            if let toastProgressViewModel = toastProgressViewModel {
                content.updateStatus(with: toastProgressViewModel.status)
            }
        }
    }

    public func enqueue(at location: QueuedViewLocation = .last, manager: ToastViewManager) {
        manager.enqueue(view: self, at: location)
    }
}
