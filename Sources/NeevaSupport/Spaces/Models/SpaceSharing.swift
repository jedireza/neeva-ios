import Apollo
import SwiftUI
import Combine

public class ContactSuggestionController: QueryController<ContactSuggestionsQuery, [ContactSuggestionController.Suggestion]> {
    public typealias Suggestion = ContactSuggestionsQuery.Data.SuggestContact.ContactSuggestion.Profile
    @Published public var query = ""

    var subscription: AnyCancellable?

    public override init() {
        super.init()
        subscription = $query
            .throttle(for: .milliseconds(200), scheduler: RunLoop.main, latest: true)
            .sink(receiveValue: { query in
                self.perform(
                    query: ContactSuggestionsQuery(query: query.replacingOccurrences(of: "@", with: " "))
                )
            })
    }

    public override class func processData(_ data: ContactSuggestionsQuery.Data, for query: ContactSuggestionsQuery) -> [Suggestion] {
        if query.query.isEmpty { return [] }
        return data.suggestContacts!.contactSuggestions!.compactMap(\.profile)
    }

    @discardableResult public static func getSuggestions(
        for query: String,
        completion: @escaping (Result<[Suggestion], Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: ContactSuggestionsQuery(query: query), completion: completion)
    }
}

extension ContactSuggestionController.Suggestion: Identifiable {
    public var id: String { email }
}

public protocol UserProfile {
    var displayName: String { get }
    var pictureUrl: String { get }
    var email: String { get }
}

extension SpaceController.Space.Acl.Profile: UserProfile {}
extension SpaceController.Space.Comment.Profile: UserProfile {}
extension SpaceController.Space.Entity.SpaceEntity.CreatedBy: UserProfile {}
extension ContactSuggestionController.Suggestion: UserProfile {}

public class UserACLController: ObservableObject {
    @Published var level: SpaceACLLevel {
        didSet {
            if !isIntializing {
                isUpdating = true
                UpdateUserSpaceAclMutation(space: spaceId, user: userId, level: level).perform { [self] result in
                    let ok: Bool
                    switch result {
                    case .success(let data):
                        ok = data.updateUserSpaceAcl
                    case .failure:
                        ok = false
                    }
                    if !ok {
                        isIntializing = true
                        level = oldValue
                        isIntializing = false
                    }
                    isUpdating = false
                }
            }
        }
    }
    @Published var isUpdating = false

    private var isIntializing = true
    private var spaceId: String
    private var userId: String

    init(spaceId: String, userId: String, level: SpaceACLLevel) {
        self.spaceId = spaceId
        self.userId = userId
        self.level = level
        self.isIntializing = false
    }
}

public class SpacePublicACLController: ObservableObject {
    @Published var hasPublicACL: Bool {
        didSet {
            if !isIntializing {
                isUpdating = true
                if hasPublicACL {
                    AddSpacePublicAclMutation(space: self.id).perform { [self] result in
                        if case .failure(_) = result {
                            isIntializing = true
                            hasPublicACL = false
                            isIntializing = false
                        }
                        isUpdating = false
                    }
                } else {
                    DeleteSpacePublicAclMutation(space: self.id).perform { [self] result in
                        if case .failure(_) = result {
                            isIntializing = true
                            hasPublicACL = true
                            isIntializing = false
                        }
                        isUpdating = false
                    }
                }
            }
        }
    }
    @Published var isUpdating = false

    private var isIntializing = true
    private var id: String

    init(id: String, hasPublicACL: Bool) {
        self.id = id
        self.hasPublicACL = hasPublicACL
        self.isIntializing = false
    }
}
