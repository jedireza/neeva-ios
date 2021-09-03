// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

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
    ) -> Apollo.Cancellable {
        Self.perform(
            query: GetContactSuggestionsQuery(
                q: query, count: count, onlyNeevaUsers: onlyNeevaUsers), completion: completion)
    }
}
