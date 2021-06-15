// Copyright Neeva. All rights reserved.

import Shared

struct ContentBlockingUtils {
    private static func readDomains() -> String? {
        if let filepath = Bundle.main.path(forResource: "trackerDomains", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                // Handle!
            }
        } else {
            // Handle!
        }
        return nil
    }

    static let maxDomainsPerRule = 20
    static let maxRulesAllowedInContentBlocker = 50000

    private static func buildRegex(domains: [String]) -> String {
        // This regex language have limited power
        // Check https://developer.apple.com/documentation/safariservices/creating_a_content_blocker
        let regex = "^(https?)?(wss?)?:[/][/](.+\\.)?(" + domains.map { (domain) -> String in
            return "(" + NSRegularExpression.escapedPattern(for: domain) + ")?"
        }.joined(separator: "") + ")" + "[/]" + ".*"
        return regex
    }

    private static func blockingRule(domains: [String], actionType: String) -> ContentBlockingRule {

        return ContentBlockingRule(
            trigger: ContentBlockingTrigger(urlFilter: buildRegex(domains: domains), urlFilterIsCaseSensitive: false, ifDomain: nil, unlessDomain: nil, resourceType: nil, loadType: [ThirdParty]),
            action: ContentBlockingAction (
                type: actionType
            )
        )
    }

    private static func blockingRules(domains: [String]) -> [ContentBlockingRule] {
        var rules: [ContentBlockingRule] = []
        var actionType: String?

        if NeevaContentBlockingConfig.blockThirdPartyTrackingRequests.IsEnabled() {
            actionType = Block
        } else if NeevaContentBlockingConfig.blockThirdPartyTrackingCookies.IsEnabled() {
            actionType = BlockCookies
        }

        if actionType != nil {
            var groupedDomains: [String] = []
            var dcount = 0
            for (_,domain) in domains.enumerated() {
                groupedDomains.append(domain)
                dcount+=1;
                if dcount == maxDomainsPerRule {
                    rules.append(blockingRule(domains: groupedDomains, actionType: actionType!))
                    dcount = 0
                    groupedDomains = []
                }
            }
            if groupedDomains.count > 0 {
                rules.append(blockingRule(domains: groupedDomains, actionType: actionType!))
            }
        }
        return rules
    }

    private static func upgradeAllToHTTPSRule() -> [ContentBlockingRule] {
        var rules: [ContentBlockingRule] = []

        if NeevaContentBlockingConfig.upgradeAllToHTTPS.IsEnabled() {
            rules.append(ContentBlockingRule(trigger: ContentBlockingTrigger(urlFilter: ".*"), action: ContentBlockingAction(type: MakeHTTPS)))
        }
        return rules
    }

    private static func unblockedRule(domains: [String]) -> ContentBlockingRule {
        return ContentBlockingRule(
            trigger: ContentBlockingTrigger(urlFilter: ".*", urlFilterIsCaseSensitive: false, ifDomain: domains, unlessDomain: nil, resourceType: nil, loadType: nil, ifTopUrl: nil),
            action: ContentBlockingAction (
                type: IgnorePreviousRules
            )
        )
    }

    private static func unblockedRules() -> [ContentBlockingRule] {
        var rules: [ContentBlockingRule] = []
        let domains = NeevaContentBlockingConfig.PerSite.getUnblockedList()

        NSLog("unblockedRules domains:", domains.count, domains)
        var groupedPatterns: [String] = []
        var dcount = 0
        for (_,domain) in domains.enumerated() {
            groupedPatterns.append("*" + domain)
            dcount+=1;
            if dcount == maxDomainsPerRule {
                rules.append(unblockedRule(domains: groupedPatterns))
                dcount = 0
                groupedPatterns = []
            }
        }
        if groupedPatterns.count > 0 {
            rules.append(unblockedRule(domains: groupedPatterns))
        }
        return rules
    }

    static func generateRules() -> [ContentBlockingRule]  {
        let domains = readDomains()
        var rules: [ContentBlockingRule] = []
        if domains != nil {
            do {
                let domainsJson: [String] = try JSONDecoder().decode([String].self, from: domains!.data(using: .utf8)!)
                rules = blockingRules(domains: domainsJson) + upgradeAllToHTTPSRule() + unblockedRules()
            } catch {
                // Handle
            }
        }
        return rules
    }

    static let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:  AppInfo.sharedContainerIdentifier)!

    public static let contentBlockerListUrl = containerUrl.appendingPathComponent("contentBlockerList").appendingPathExtension("json")

    public static func contentBlockerExists()-> Bool {
        if FileManager.default.fileExists(atPath: contentBlockerListUrl.path) {
            return true
        }
        return false
    }


    static func generateContentBlocker()-> URL {
        let rules = generateRules()

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(rules)
            try data.write(to: contentBlockerListUrl, options: .atomic)
        } catch {
        }
        return contentBlockerListUrl
    }
}
