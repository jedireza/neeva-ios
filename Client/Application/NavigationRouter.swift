/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import Shared

extension URLComponents {
    // Return the first query parameter that matches
    func valueForQuery(_ param: String) -> String? {
        return self.queryItems?.first { $0.name == param }?.value
    }
}

// The root navigation for the Router. Look at the tests to see a complete URL
enum NavigationPath {
    case url(webURL: URL?, isPrivate: Bool)
    case widgetUrl(webURL: URL?, uuid: String)
    case text(String)
    case closePrivateTabs

    init?(url: URL) {
        let urlString = url.absoluteString
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        guard
            let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes")
                as? [AnyObject],
            let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String]
        else {
            // Something very strange has happened
            return nil
        }

        guard let scheme = components.scheme, urlSchemes.contains(scheme) else {
            return nil
        }

        if urlString.starts(with: "\(scheme)://open-url") {
            self = .openUrlFromComponents(components: components)
        } else if let widgetKitNavPath = NavigationPath.handleWidgetKitQuery(
            urlString: urlString, scheme: scheme, components: components)
        {
            self = widgetKitNavPath
        } else if urlString.starts(with: "\(scheme)://open-text") {
            let text = components.valueForQuery("text")
            self = .text(text ?? "")
        } else if urlString.starts(with: "http:") || urlString.starts(with: "https:") {
            // Use the last browsing mode the user was in
            let isPrivate = UserDefaults.standard.bool(forKey: "wasLastSessionPrivate")
            self = .url(
                webURL: NavigationPath.maybeRewriteURL(url, components), isPrivate: isPrivate)
        } else {
            return nil
        }
    }

    static func handle(nav: NavigationPath, with bvc: BrowserViewController) {
        switch nav {
        case .url(let url, let isPrivate):
            NavigationPath.handleURL(url: url, isPrivate: isPrivate, with: bvc)
        case .text(let text):
            NavigationPath.handleText(text: text, with: bvc)
        case .closePrivateTabs:
            NavigationPath.handleClosePrivateTabs(with: bvc)
        case .widgetUrl(let webURL, let uuid):
            NavigationPath.handleWidgetURL(url: webURL, uuid: uuid, with: bvc)
        }
    }

    private static func handleWidgetKitQuery(
        urlString: String, scheme: String, components: URLComponents
    ) -> NavigationPath? {
        if urlString.starts(with: "\(scheme)://widget-medium-topsites-open-url") {
            // Widget Top sites - open url
            return .openUrlFromComponents(components: components)
        } else if urlString.starts(with: "\(scheme)://widget-small-quicklink-open-url") {
            // Widget Quick links - small - open url private or regular
            return .openUrlFromComponents(components: components)
        } else if urlString.starts(with: "\(scheme)://widget-medium-quicklink-open-url") {
            // Widget Quick Actions - medium - open url private or regular
            return .openUrlFromComponents(components: components)
        } else if urlString.starts(with: "\(scheme)://widget-small-quicklink-open-copied")
            || urlString.starts(with: "\(scheme)://widget-medium-quicklink-open-copied")
        {
            // Widget Quick links - medium - open copied url
            return .openCopiedUrl()
        } else if urlString.starts(with: "\(scheme)://widget-small-quicklink-close-private-tabs")
            || urlString.starts(with: "\(scheme)://widget-medium-quicklink-close-private-tabs")
        {
            // Widget Quick links - medium - close private tabs
            return .closePrivateTabs
        }

        return nil
    }

    private static func openUrlFromComponents(components: URLComponents) -> NavigationPath {
        let url = components.valueForQuery("url")?.asURL

        // If attempting to sign in, skip first run screen
        if let url = url, NeevaConstants.isAppHost(url.host), url.path.starts(with: "/login") {
            Defaults[.introSeen] = true

            let bvc = SceneDelegate.getBVC()
            if let introVC = bvc.introViewController {
                bvc.view.alpha = 1
                introVC.dismiss(animated: true, completion: nil)
            }
        }

        // Unless the `open-url` URL specifies a `private` parameter,
        // use the last browsing mode the user was in.
        let isPrivate =
            Bool(components.valueForQuery("private") ?? "")
            ?? UserDefaults.standard.bool(forKey: "wasLastSessionPrivate")
        return .url(webURL: url, isPrivate: isPrivate)
    }

    private static func openCopiedUrl() -> NavigationPath {
        if !UIPasteboard.general.hasURLs {
            let searchText = UIPasteboard.general.string ?? ""
            return .text(searchText)
        }
        let url = UIPasteboard.general.url
        let isPrivate = UserDefaults.standard.bool(forKey: "wasLastSessionPrivate")
        return .url(webURL: url, isPrivate: isPrivate)
    }

    private static func handleClosePrivateTabs(with bvc: BrowserViewController) {
        bvc.tabManager.removeTabs(bvc.tabManager.privateTabs)
        guard let tab = mostRecentTab(inTabs: bvc.tabManager.normalTabs) else {
            bvc.tabManager.selectTab(bvc.tabManager.addTab())
            return
        }
        bvc.tabManager.selectTab(tab)
    }

    private static func handleURL(url: URL?, isPrivate: Bool, with bvc: BrowserViewController) {
        if let newURL = url {
            bvc.switchToTabForURLOrOpen(newURL, isPrivate: isPrivate)
        } else {
            bvc.openBlankNewTab(focusLocationField: true, isPrivate: isPrivate)
        }
    }

    private static func handleWidgetURL(url: URL?, uuid: String, with bvc: BrowserViewController) {
        if let newURL = url {
            bvc.switchToTabForWidgetURLOrOpen(newURL, uuid: uuid, isPrivate: false)
        } else {
            bvc.openBlankNewTab(focusLocationField: true, isPrivate: false)
        }
    }

    private static func handleText(text: String, with bvc: BrowserViewController) {
        bvc.openBlankNewTab(focusLocationField: false)
        bvc.urlBar(didSubmitText: text)
    }

    public static func maybeRewriteURL(_ url: URL, _ components: URLComponents) -> URL {
        // Intercept and rewrite search queries incoming from e.g. SpotLight.
        //
        // Example of what components looks like:
        //    - scheme : "https"
        //    - host : "www.google.com"
        //    - path : "/search"
        //    ▿ queryItems : 5 elements
        //      ▿ 0 : q=foo+bar
        //        - name : "q"
        //        ▿ value : Optional<String>
        //          - some : "foo+bar"
        //      ▿ 1 : ie=UTF-8
        //        - name : "ie"
        //        ▿ value : Optional<String>
        //          - some : "UTF-8"
        //      ▿ 2 : oe=UTF-8
        //        - name : "oe"
        //        ▿ value : Optional<String>
        //          - some : "UTF-8"
        //      ▿ 3 : hl=en
        //        - name : "hl"
        //        ▿ value : Optional<String>
        //          - some : "en"
        //      ▿ 4 : client=safari
        //        - name : "client"
        //        ▿ value : Optional<String>
        //          - some : "safari"
        //

        // search query value
        var value: String?

        if let host = components.host, let queryItems = components.percentEncodedQueryItems {
            switch host {
            case "www.google.com", "www.bing.com", "www.ecosia.org", "search.yahoo.com":
                // yahoo uses p for the search query name instead of q
                let queryName = host == "search.yahoo.com" ? "p" : "q"
                if components.path == "/search" {
                    value = queryItems.first(where: { $0.name == queryName })?.value
                }
            case "duckduckgo.com":
                // duckduckgo doesn't include the /search path
                value = queryItems.first(where: { $0.name == "q" })?.value
            case "yandex.com":
                if components.path == "/search/touch/" {
                    value = queryItems.first(where: { $0.name == "text" })?.value
                }
            case "www.baidu.com", "www.so.com":
                let queryName = host == "www.baidu.com" ? "oq" : "src"
                if components.path == "/s" {
                    value = queryItems.first(where: { $0.name == queryName })?.value
                }
            case "www.sogou.com":
                if components.path == "/web" {
                    value = queryItems.first(where: { $0.name == "query" })?.value
                }
            default:
                return url
            }
        }

        if let value = value?.replacingOccurrences(of: "+", with: " ").removingPercentEncoding, let newURL = neevaSearchEngine.searchURLForQuery(value) {
            return newURL
        } else {
            return url
        }
    }
}

extension NavigationPath: Equatable {}

func == (lhs: NavigationPath, rhs: NavigationPath) -> Bool {
    switch (lhs, rhs) {
    case let (.url(lhsURL, lhsPrivate), .url(rhsURL, rhsPrivate)):
        return lhsURL == rhsURL && lhsPrivate == rhsPrivate
    default:
        return false
    }
}
