/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Shared

struct TPPageStats {
    var domains: [String]

    init() {
        domains = [String]();
    }

    private init(domains: [String], host: String) {
        self.domains = domains
        self.domains.append(host);
    }

    func create(host: String) -> TPPageStats {
        return TPPageStats(domains: domains, host: host)
    }
}

class TPStatsBlocklistChecker {
    static let shared = TPStatsBlocklistChecker()

    // Initialized async, is non-nil when ready to be used.
    private var blockLists: TPStatsBlocklists?

    func isBlocked(url: URL, mainDocumentURL: URL) -> Deferred<Bool> {
        let deferred = Deferred<Bool>()

        guard let blockLists = blockLists, let host = url.host, !host.isEmpty else {
            // TP Stats init isn't complete yet
            deferred.fill(false)
            return deferred
        }

        guard let domain = url.baseDomain, let docDomain = mainDocumentURL.baseDomain, domain != docDomain else {
            deferred.fill(false)
            return deferred
        }

        // Make a copy on the main thread
        let safelistRegex = TrackingPreventionConfig.unblockedDomainsRegex

        DispatchQueue.global().async {
            // Return true in the Deferred if the domain could potentially be blocked
            deferred.fill(blockLists.urlIsInList(url,
                                                 mainDocumentURL: mainDocumentURL,
                                                 safelistedDomains: safelistRegex))
        }
        return deferred
    }

    func startup() {
        DispatchQueue.global().async {
            let parser = TPStatsBlocklists()
            parser.load()
            DispatchQueue.main.async {
                self.blockLists = parser
            }
        }
    }
}

// The 'unless-domain' and 'if-domain' rules use wildcard expressions, convert this to regex.
func wildcardContentBlockerDomainToRegex(domain: String) -> String? {
    struct Memo { static var domains = [String: String]() }
    
    if let memoized = Memo.domains[domain] {
        return memoized
    }

    // Convert the domain exceptions into regular expressions.
    var regex = domain + "$"
    if regex.first == "*" {
        regex = "." + regex
    }
    regex = regex.replacingOccurrences(of: ".", with: "\\.")
    
    Memo.domains[domain] = regex
    return regex
}

class TPStatsBlocklists {

    func load() {
        TrackingPreventionUtils.generateRules()
    }

    func urlIsInList(_ url: URL, mainDocumentURL: URL, safelistedDomains: [String]) -> Bool {
        if (ContentBlocker.shared.setupCompleted && TrackingPreventionUtils.domainSet.contains(url.baseDomain ?? "")) {
            return true
        }

        return false
    }
}
