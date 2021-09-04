// Copyright Neeva. All rights reserved.

import Foundation

public enum FeedbackRequestState {
    case inProgress
    case success
    case failed
}

let logger = Logger.browser

public class FeedbackRequest: ObservableObject {
    @Published public var state: FeedbackRequestState = .inProgress

    private var feedback: SendFeedbackMutation

    public func sendFeedback() {
        feedback.perform { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.updateTourManagerUponSuccess()
                self.state = .success
            case .failure(let error):
                self.state = .failed
                logger.error(error)
            }

            TourManager.shared.reset()
        }
    }

    private func updateTourManagerUponSuccess() {
        TourManager.shared.userReachedStep(step: .promptFeedbackInNeevaMenu)
        TourManager.shared.userReachedStep(step: .openFeedbackPanelWithInputFieldHighlight)
    }

    init(feedback: SendFeedbackMutation) {
        self.feedback = feedback
        sendFeedback()
    }
}
