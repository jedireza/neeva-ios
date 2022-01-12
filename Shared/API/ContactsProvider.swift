// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine

public class ContactsProvider: QueryController<
    GetContactSuggestionsQuery,
    [GetContactSuggestionsQuery.Data.SuggestContact.ContactSuggestion.Profile?]
>
{
    public typealias Profile = GetContactSuggestionsQuery.Data.SuggestContact.ContactSuggestion
        .Profile

    public override class func processData(_ data: GetContactSuggestionsQuery.Data) -> [Profile?] {
        data.suggestContacts?.contactSuggestions?.map { $0.profile } ?? []
    }

    @discardableResult public static func getContacts(
        for query: String, count: Int = 5, onlyNeevaUsers: Bool = false,
        completion: @escaping (Result<[Profile?], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(
            query: GetContactSuggestionsQuery(
                q: query, count: count, onlyNeevaUsers: onlyNeevaUsers), completion: completion)
    }
}
