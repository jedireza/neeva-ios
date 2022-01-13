// Copyright Neeva. All rights reserved.

import Apollo
import Foundation
import Shared

public let WEB3_SUBMISSION_QUERY = "Web3 Community Submission Label"

public class SuppressRequest: MutationRequest<CommunitySuppressResultMutation> {
    public init(url: URL) {
        super.init(
            mutation: CommunitySuppressResultMutation(
                input: CommunitySuppressResultInput(
                    query: WEB3_SUBMISSION_QUERY,
                    url: url.absoluteString,
                    universalType: "web3Univ",
                    navTreatmentOnly: false,
                    reason: "Web3 Submission Test please ignore"
                )))
    }
}

public class BoostRequest: MutationRequest<CommunityBoostResultMutation> {
    public init(url: URL) {
        super.init(
            mutation: CommunityBoostResultMutation(
                input: CommunityBoostResultInput(
                    query: WEB3_SUBMISSION_QUERY,
                    url: url.absoluteString,
                    universalType: "web3Univ"
                )))
    }
}
