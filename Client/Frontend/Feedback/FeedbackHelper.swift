// Copyright Neeva. All rights reserved.

import Foundation

func showFeedbackPanel(
    bvc: BrowserViewController, screenshot: UIImage? = nil, shareURL: Bool = true
) {
    let url = shareURL ? bvc.tabManager.selectedTab?.canonicalURL : nil
    let query = neevaSearchEngine.queryForSearchURL(url)

    getSearchRequestID(bvc: bvc) { requestId in
        bvc.present(
            SendFeedbackPanel(
                requestId: requestId, screenshot: screenshot, url: url, query: query,
                onOpenURL: {
                    bvc.dismiss(animated: true, completion: nil)
                    bvc.openURLInNewTab($0)
                }), animated: true)
    }
}

func getSearchRequestID(
    bvc: BrowserViewController, completion: @escaping (_ requestIdString: String?) -> Void
) {
    if let webView = bvc.tabManager.selectedTab?.webView {
        webView.evaluateJavaScript("window.__neevaNativeBridge.messaging.getRequestID()") {
            (data, error) in
            completion(data as? String)
            if let error = error {
                print("evaluateJavaScript Error : \(String(describing: error))")
            }
        }
    }
}
