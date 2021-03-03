/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage

extension BrowserViewController {
    func share(fileURL: URL, buttonView: UIView, presentableVC: PresentableVC) {
        let helper = ShareExtensionHelper(url: fileURL, tab: tabManager.selectedTab)
        let controller = helper.createActivityViewController { completed, activityType in
            print("Shared downloaded file: \(completed)")
        }

        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = buttonView
            popoverPresentationController.sourceRect = buttonView.bounds
            popoverPresentationController.permittedArrowDirections = .up
        }

        presentableVC.present(controller, animated: true, completion: nil)
    }

    func share(tab: Tab, from sourceView: UIView, presentableVC: PresentableVC) {
        guard let url = tab.canonicalURL?.displayURL else { return }

        if let temporaryDocument = tab.temporaryDocument {
            temporaryDocument.getURL().uponQueue(.main, block: { tempDocURL in
                // If we successfully got a temp file URL, share it like a downloaded file,
                // otherwise present the ordinary share menu for the web URL.
                if tempDocURL.isFileURL {
                    self.share(fileURL: tempDocURL, buttonView: sourceView, presentableVC: presentableVC)
                } else {
                    self.presentActivityViewController(url, tab: tab, sourceView: sourceView, sourceRect: sourceView.bounds, arrowDirection: .up)

                }
            })
        } else {
            self.presentActivityViewController(url, tab: tab, sourceView: view, sourceRect: sourceView.bounds, arrowDirection: .up)
        }
    }

    func getTabActions(tab: Tab, buttonView: UIView,
                       findInPage:  @escaping () -> Void,
                       presentableVC: PresentableVC,
                       deferredPinnedTopSiteStatus: Deferred<Maybe<Bool>>,
                       shouldShowReloadButton: Bool,
                       success: @escaping (String) -> Void) -> [[UIMenuElement]] {
        if tab.url?.isFileURL ?? false {
            let shareFile = UIAction(title: Strings.AppMenuSharePageTitleString, image: UIImage(systemName: "square.and.arrow.up")) { _ in
                guard let url = tab.url else { return }

                self.share(fileURL: url, buttonView: buttonView, presentableVC: presentableVC)
            }

            return [[shareFile]]
        }

        let toggleDesktopSite = toggleDesktopSiteAction(for: tab)

        let savePageToSpace = UIAction(title: "Save to Space", image: UIImage(systemName: "bookmark")) { _ in
            guard let url = tab.canonicalURL?.displayURL,
                  let bvc = presentableVC as? BrowserViewController else {
                return
            }
            tab.webView!.evaluateJavaScript("document.querySelector('meta[name=\"description\"]').content") { (result, error) in
                bvc.present(AddToSpaceViewController(
                    title: tab.title ?? url.absoluteString,
                    description: result as? String,
                    url: url,
                    onDismiss: { _ in
                        bvc.dismissVC()
                        success("Added to Space")
                    },
                    onOpenURL: {
                        bvc.dismissVC()
                        bvc.openURLInNewTab($0)
                    }
                ), animated: true)
            }
        }

        let pinToTopSites = UIAction(title: Strings.PinTopsiteActionTitle, image: UIImage(systemName: "pin")) { _ in
            guard let url = tab.url?.displayURL, let sql = self.profile.history as? SQLiteHistory else { return }

            sql.getSites(forURLs: [url.absoluteString]).bind { val -> Success in
                guard let site = val.successValue?.asArray().first?.flatMap({ $0 }) else {
                    return succeed()
                }
                return self.profile.history.addPinnedTopSite(site)
            }.uponQueue(.main) { result in
                if result.isSuccess {
                    success(Strings.AppMenuAddPinToTopSitesConfirmMessage)
                }
            }
        }

        let removeTopSitesPin = UIAction(title: Strings.RemovePinTopsiteActionTitle, image: UIImage(systemName: "pin.slash")) { _ in
            guard let url = tab.url?.displayURL, let sql = self.profile.history as? SQLiteHistory else { return }

            sql.getSites(forURLs: [url.absoluteString]).bind { val -> Success in
                guard let site = val.successValue?.asArray().first?.flatMap({ $0 }) else {
                    return succeed()
                }

                return self.profile.history.removeFromPinnedTopSites(site)
            }.uponQueue(.main) { result in
                if result.isSuccess {
                    success(Strings.AppMenuRemovePinFromTopSitesConfirmMessage)
                }
            }
        }

        let copyURL = UIAction(title: Strings.AppMenuCopyURLTitleString, image: UIImage(systemName: "link")) { _ in
            if let url = tab.canonicalURL?.displayURL {
                UIPasteboard.general.url = url
                success(Strings.AppMenuCopyURLConfirmMessage)
            }
        }
        
        let refreshPage = UIAction(title: Strings.ReloadPageTitle, image: UIImage(systemName: "arrow.clockwise")) { _ in
            self.tabManager.selectedTab?.reload()
        }
        
        let stopRefreshPage = UIAction(title: Strings.StopReloadPageTitle, image: UIImage(systemName: "xmark")) { _ in
            self.tabManager.selectedTab?.stop()
        }
        
        let refreshAction = tab.loading ? stopRefreshPage : refreshPage
        var refreshActions = [refreshAction]
        
        if let url = tab.webView?.url, let helper = tab.contentBlocker, helper.isEnabled, helper.blockingStrengthPref == .strict {
            let isSafelisted = helper.status == .safelisted
            
            let title = !isSafelisted ? Strings.TrackingProtectionReloadWithout : Strings.TrackingProtectionReloadWith
            let imageName = helper.isEnabled ? "shield.lefthalf.fill.slash" : "shield.lefthalf.fill"
            let toggleTP = UIAction(title: title, image: UIImage(systemName: imageName)) { _ in
                ContentBlocker.shared.safelist(enable: !isSafelisted, url: url) {
                    tab.reload()
                }
            }
            refreshActions.append(toggleTP)
        }
        
        var mainActions: [UIAction] = []

        if !tab.isPrivate {
            mainActions.append(savePageToSpace)
        }

        mainActions.append(contentsOf: [copyURL])

        let pinAction = UIDeferredMenuElement { provideElements in
            deferredPinnedTopSiteStatus.uponQueue(.main) {
                let isPinned = $0.successValue ?? false
                provideElements([isPinned ? removeTopSitesPin : pinToTopSites])
            }
        }
        var commonActions = [toggleDesktopSite, pinAction]

        // Disable find in page if document is pdf.
        if tab.mimeType != MIMEType.PDF {
            let findInPageAction = UIAction(title: Strings.AppMenuFindInPageTitleString, image: UIImage(systemName: "magnifyingglass")) { _ in
                findInPage()
            }
            commonActions.insert(findInPageAction, at: 0)
        }

        if shouldShowReloadButton && tab.readerModeAvailableOrActive {
            return [refreshActions, mainActions, commonActions]
        } else {
            return [mainActions, commonActions]
        }
    }

}
