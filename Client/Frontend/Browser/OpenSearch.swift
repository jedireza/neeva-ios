/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Fuzi
import Shared
import UIKit

class OpenSearchEngine {
    let shortName: String
    let engineID: String?
    let image: UIImage
    let isCustomEngine: Bool

    fileprivate let SearchTermComponent = "{searchTerms}"
    fileprivate let LocaleTermComponent = "{moz:locale}"

    fileprivate lazy var searchQueryComponentKey: String? = { [unowned self] in
        self.getQueryArgFromTemplate()
    }()

    var searchTemplate: String {
        "https://\(NeevaConstants.appHost)/search?q={searchTerms}&src=nvobar"
    }

    init(engineID: String?, shortName: String, image: UIImage, isCustomEngine: Bool) {
        self.shortName = shortName
        self.image = image
        self.isCustomEngine = isCustomEngine
        self.engineID = engineID
    }

    /// Returns the search URL for the given query.
    func searchURLForQuery(_ query: String) -> URL? {
        return getURLFromTemplate(searchTemplate, query: query)
    }

    /// Return the arg that we use for searching for this engine
    fileprivate func getQueryArgFromTemplate() -> String? {
        // we have the replace the templates SearchTermComponent in order to make the template
        // a valid URL, otherwise we cannot do the conversion to NSURLComponents
        // and have to do flaky pattern matching instead.
        let placeholder = "PLACEHOLDER"
        let template = searchTemplate.replacingOccurrences(
            of: SearchTermComponent, with: placeholder)
        var components = URLComponents(string: template)

        if let retVal = extractQueryArg(in: components?.queryItems, for: placeholder) {
            return retVal
        } else {
            // Query arg may be exist inside fragment
            components = URLComponents()
            components?.query = URL(string: template)?.fragment
            return extractQueryArg(in: components?.queryItems, for: placeholder)
        }
    }

    fileprivate func extractQueryArg(in queryItems: [URLQueryItem]?, for placeholder: String)
        -> String?
    {
        let searchTerm = queryItems?.filter { item in
            return item.value == placeholder
        }
        return searchTerm?.first?.name
    }

    /// check that the URL host contains the name of the search engine somewhere inside it
    fileprivate func isSearchURLForEngine(_ url: URL?) -> Bool {
        guard  url?.path == NeevaConstants.appSearchURL.path,
            let urlHost = url?.shortDisplayString,
            let queryEndIndex = searchTemplate.range(of: "?")?.lowerBound,
            let templateURL = URL(string: String(searchTemplate[..<queryEndIndex]))
        else { return false }

        return urlHost == templateURL.shortDisplayString
    }

    /// Returns the query that was used to construct a given search URL
    func queryForSearchURL(_ url: URL?) -> String? {
        guard isSearchURLForEngine(url), let key = searchQueryComponentKey else { return nil }

        if let value = url?.getQuery()[key] {
            return value.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
        } else {
            // If search term could not found in query, it may be exist inside fragment
            var components = URLComponents()
            components.query = url?.fragment?.removingPercentEncoding

            guard let value = components.url?.getQuery()[key] else { return nil }
            return value.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
        }
    }

    func queryForLocationBar(from url: URL?) -> String? {
        let showQueryInLocationBar = NeevaFeatureFlags[.clientHideSearchBox]
        if showQueryInLocationBar, let query = queryForSearchURL(url),
            !NeevaConstants.isNeevaPageWithSearchBox(url: url)
        {
            return query
        }
        return nil
    }

    fileprivate func getURLFromTemplate(_ searchTemplate: String, query: String) -> URL? {
        if let escapedQuery = query.addingPercentEncoding(
            withAllowedCharacters: .SearchTermsAllowed)
        {
            // Escape the search template as well in case it contains not-safe characters like symbols
            let templateAllowedSet = NSMutableCharacterSet()
            templateAllowedSet.formUnion(with: .URLAllowed)

            // Allow brackets since we use them in our template as our insertion point
            templateAllowedSet.formUnion(with: CharacterSet(charactersIn: "{}"))

            if let encodedSearchTemplate = searchTemplate.addingPercentEncoding(
                withAllowedCharacters: templateAllowedSet as CharacterSet)
            {
                let localeString = Locale.current.identifier
                let urlString =
                    encodedSearchTemplate
                    .replacingOccurrences(
                        of: SearchTermComponent, with: escapedQuery, options: .literal, range: nil
                    )
                    .replacingOccurrences(
                        of: LocaleTermComponent, with: localeString, options: .literal, range: nil)
                return URL(string: urlString)
            }
        }

        return nil
    }

    func searchURLFrom(searchQuery: String, queryItems: [URLQueryItem]) -> URL {
        let url = URL(string: "https://\(NeevaConstants.appHost)/search")!
        var queryItems = queryItems

        if let queryIndex = queryItems.firstIndex(where: { $0.name == "q" }) {
            // First item is always the search query
            queryItems[queryIndex].value = searchQuery
        }

        return url.withQueryParams(queryItems)
    }
}
