// Copyright Neeva. All rights reserved.

import UIKit
import SwiftUI
import Shared

class ToastDefaults: NSObject {
    var toast: ToastView?
    var toastProgressViewModel: ToastProgressViewModel?

    private var spaceRequestListener: Any?

    func showToastForClosedTabs(_ savedTabs: [SavedTab], tabManager: TabManager) {
        guard savedTabs.count > 0 else {
            return
        }

        var toastText = "Tab Closed"

        if savedTabs.count > 0 {
            if savedTabs.count > 1 {
                toastText = "\(savedTabs.count) Tabs Closed"
            }

            let toastContent = ToastViewContent(normalContent: ToastStateContent(text: toastText, buttonText: "restore", buttonAction: {
                // restores last closed tab
                _ = tabManager.restoreSavedTabs(savedTabs)
            }))

            let toastView = ToastViewManager.shared.makeToast(content: toastContent)

            toast = toastView
            ToastViewManager.shared.enqueue(toast: toastView)
        }
    }

    func showToastForDownload(download: Download) {
        toastProgressViewModel = ToastProgressViewModel()
        toastProgressViewModel?.status = .inProgress

        download.delegate = self

        let normalContent = ToastStateContent(text: "Downloading", buttonText: "cancel") {
            download.cancel()
        }
        let completedContent = ToastStateContent(text: "Downloaded", buttonText: "open") {
            BrowserViewController.foregroundBVC().showLibrary(panel: .downloads)
        }
        let failedContent = ToastStateContent(text: "Download Failed")

        let toastContent = ToastViewContent(normalContent: normalContent, completedContent: completedContent, failedContent: failedContent)
        let toastView = ToastViewManager.shared.makeToast(content: toastContent, toastProgressViewModel: toastProgressViewModel, autoDismiss: false)

        toast = toastView
        ToastViewManager.shared.enqueue(toast: toastView, at: .first)
    }

    func showToastForSpace(request: AddToSpaceRequest) {
        toastProgressViewModel = ToastProgressViewModel()
        toastProgressViewModel?.status = .inProgress

        spaceRequestListener = request.$state.sink { [self] updatedState in
            // set to success because that is the only case possible in this case
            toastProgressViewModel?.status = .success
        }

        let spaceName = request.targetSpaceName ?? "## Unknown ##"
        var completedText: String!
        var toastText: String {
            switch request.state {
            case .initial:
                assert(false)  // Should not be reached
                return ""
            case .creatingSpace, .savingToSpace:
                completedText = "Saved to \"\(spaceName)\""
                return "Saving..."
            case .savedToSpace:
                completedText = "Saved to \"\(spaceName)\""
                return "Saved to \"\(spaceName)\""
            case .deletingFromSpace:
                completedText = "Deleted from \"\(spaceName)\""
                return "Deleting..."
            case .deletedFromSpace:
                completedText = "Deleted from \"\(spaceName)\""
                return "Deleted from \"\(spaceName)\""
            case .failed:
                return "Failed to save to \"\(spaceName)\""
            }
        }

        let buttonAction = {
            let bvc = BrowserViewController.foregroundBVC()
            bvc.openURLInNewTab(NeevaConstants.appSpacesURL / request.targetSpaceID!)
        }

        let failedAction = {
            if let toastProgressViewModel = self.toastProgressViewModel {
                toastProgressViewModel.status = .inProgress
            }
        }

        let normalContent = ToastStateContent(text: toastText, buttonText: "open space", buttonAction: buttonAction)
        let completedContent = ToastStateContent(text: completedText, buttonText: "open space", buttonAction: buttonAction)
        let failedContent = ToastStateContent(text: "Failed to save to \"\(spaceName)\"", buttonText: "try again", buttonAction: failedAction)
        let toastContent = ToastViewContent(normalContent: normalContent, completedContent: completedContent, failedContent: failedContent)

        let toastView = ToastViewManager.shared.makeToast(content: toastContent, toastProgressViewModel: toastProgressViewModel, autoDismiss: false)
        toast = toastView
        ToastViewManager.shared.enqueue(toast: toastView)
    }
}

extension ToastDefaults: DownloadDelegate {
    func download(_ download: Download, didDownloadBytes bytesDownloaded: Int64) {

    }

    func download(_ download: Download, didFinishDownloadingTo location: URL) {
        toastProgressViewModel?.status = .success
        downloadComplete()
    }

    func download(_ download: Download, didCompleteWithError error: Error?) {
        if error != nil {
            print("Download failed with error:", error as Any)

            toastProgressViewModel?.status = .success
            downloadComplete()
        }
    }

    func downloadComplete() {
        self.toast = nil
    }
}
