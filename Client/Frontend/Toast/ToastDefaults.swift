// Copyright Neeva. All rights reserved.

import UIKit

class ToastDefaults: NSObject {
    var toast: ToastView?
    var toastProgressViewModel: ToastProgressViewModel?

    func showToastForClosedTabs(_ savedTabs: [SavedTab], tabManager: TabManager) {
        guard savedTabs.count > 0 else {
            return
        }

        let savedTabs = savedTabs.filter { !$0.isPrivate }
        var toastText: String!

        if savedTabs.count > 1 {
            toastText = "\(savedTabs.count) Tabs Closed"
        } else  {
            toastText = "Tab Closed"
        }

        let toastContent = ToastViewContent(normalContent: ToastStateContent(text: toastText, buttonText: "restore", buttonAction: {
            // restores last closed tab
            tabManager.restoreSavedTabs(savedTabs)
        }))

        let toastView = ToastViewManager.shared.makeToast(content: toastContent)

        toast = toastView
        ToastViewManager.shared.enqueue(toast: toastView)
    }

    func showToastForDownload(download: Download) {
        toastProgressViewModel = ToastProgressViewModel()
        toastProgressViewModel?.status = .inProgress
        toastProgressViewModel?.download = download

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
