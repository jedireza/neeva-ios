// Copyright Neeva. All rights reserved.

import Apollo
import Foundation
import Shared

public let WEB3_SUBMISSION_QUERY = "Web3 Community Submission Label"
public let TEMP_WEB3_ALLOW_LIST = ["opensea.io", "superrare.com", "rarible.com", "foundation.app"]

public class SuppressRequest: MutationRequest<CommunitySuppressResultMutation> {
    public init(url: URL) {
        super.init(
            mutation: CommunitySuppressResultMutation(
                input: CommunitySuppressResultInput(
                    query: WEB3_SUBMISSION_QUERY,
                    url: url.domainURL.absoluteString,
                    universalType: "web",
                    navTreatmentOnly: true,
                    reason: "Web3 Trust Signal Submission"
                )))
    }
}

public class BoostRequest: MutationRequest<CommunityBoostResultMutation> {
    public init(url: URL) {
        super.init(
            mutation: CommunityBoostResultMutation(
                input: CommunityBoostResultInput(
                    query: WEB3_SUBMISSION_QUERY,
                    url: url.domainURL.absoluteString,
                    universalType: "web",
                    asNav: true,
                    userComment: "Web3 Trust Signal Submission"
                )))
    }
}
