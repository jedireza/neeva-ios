/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

extension BrowserViewController: DownloadQueueDelegate {
    func downloadQueue(_ downloadQueue: DownloadQueue, didStartDownload download: Download) {
        ToastDefaults().showToastForDownload(download: download, toastViewManager: toastViewManager)
    }

    func downloadQueue(
        _ downloadQueue: DownloadQueue, didDownloadCombinedBytes combinedBytesDownloaded: Int64,
        combinedTotalBytesExpected: Int64?
    ) {

    }

    func downloadQueue(
        _ downloadQueue: DownloadQueue, download: Download, didFinishDownloadingTo location: URL
    ) {
        print("didFinishDownloadingTo(): \(location)")
    }

    func downloadQueue(_ downloadQueue: DownloadQueue, didCompleteWithError error: Error?) {
    }
}
