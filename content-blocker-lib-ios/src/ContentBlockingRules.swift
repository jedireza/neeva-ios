// Copyright Neeva. All rights reserved.

import Foundation

// These structures are built on
// https://developer.apple.com/documentation/safariservices/creating_a_content_blocker

// FirstParty
let FirstParty = "first-party"
let ThirdParty = "third-party"

struct ContentBlockingTrigger: Encodable {
    enum CodingKeys: String, CodingKey {
        case urlFilter = "url-filter"
        case urlFilterIsCaseSensitive = "url-filter-is-case-sensitive"
        case ifDomain = "if-domain"
        case unlessDomain = "unless-domain"
        case resourceType = "resource-type"
        case loadType = "load-type"
        case ifTopUrl = "if-top-url"
        case unlessTopUrl = "unless-top-url"
    }

    var urlFilter: String
    var urlFilterIsCaseSensitive: Bool?
    var ifDomain: [String]?
    var unlessDomain: [String]?
    var resourceType: [String]?
    var loadType: [String]?
    var ifTopUrl: [String]?
    var unlessTopUrl: [String]?
}


// Block - block the request from getting triggred
let Block = "block"
// BlockCookies - block all cookies in outgoing request
let BlockCookies = "block-cookies"
// CSSDisplayNone - add `display: none` to the nodes filtered by selector
let CSSDisplayNone = "css-display-none"
// IgnorePreviousRules - ignore all previous rules
let IgnorePreviousRules = "ignore-previous-rules"
// MakeHTTPS - conver all requests to HTTPS
let MakeHTTPS = "make-https"


struct ContentBlockingAction: Encodable {
    var type: String
    var selector: String?
}

struct ContentBlockingRule: Encodable {
    var trigger: ContentBlockingTrigger
    var action: ContentBlockingAction
}
