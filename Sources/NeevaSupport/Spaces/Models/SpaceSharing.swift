import Apollo
import SwiftUI
import Combine

/// Provides suggested contacts based on a query
class ContactSuggestionController: QueryController<ContactSuggestionsQuery, [ContactSuggestionController.Suggestion]> {
    typealias Suggestion = ContactSuggestionsQuery.Data.SuggestContact.ContactSuggestion.Profile

    /// Bind this to a `TextField` or similar to generate search suggestions for the user’s input.
    @Published var query = ""

    var subscription: AnyCancellable?

    /// - Parameter animation: the animation to perform when new suggestions are loaded
    override init(animation: Animation? = nil) {
        super.init(animation: animation)
        subscription = $query
            .throttle(for: .milliseconds(200), scheduler: RunLoop.main, latest: true)
            .sink { _ in self.reload() }
    }

    override func reload() {
        self.perform(
            query: ContactSuggestionsQuery(query: query.replacingOccurrences(of: "@", with: " "))
        )
    }

    override class func processData(_ data: ContactSuggestionsQuery.Data, for query: ContactSuggestionsQuery) -> [Suggestion] {
        if query.query.isEmpty { return [] }
        return data.suggestContacts!.contactSuggestions!.compactMap(\.profile)
    }

    @discardableResult static func getSuggestions(
        for query: String,
        completion: @escaping (Result<[Suggestion], Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: ContactSuggestionsQuery(query: query), completion: completion)
    }
}

extension ContactSuggestionController.Suggestion: Identifiable {
    public var id: String { email }
}

/// A common interface exposed by objects at various locations in the schema
/// If you need to display a user somewhere else in the app, feel free to conform
/// addtional types to this protocol.
protocol UserProfile {
    var displayName: String { get }
    var pictureUrl: String { get }
    var email: String { get }
}

extension SpaceController.Space.Acl.Profile: UserProfile {}
extension SpaceController.Space.Comment.Profile: UserProfile {}
extension SpaceController.Space.Entity.SpaceEntity.CreatedBy: UserProfile {}
extension ContactSuggestionController.Suggestion: UserProfile {}

/// Updates a user’s access level
class UserACLController: ObservableObject {
    /// Bind this to a `Picker` or other input view, or manually assign a value.
    /// The user’s access level will be updated whenever its value is changed
    @Published var level: SpaceACLLevel {
        didSet {
            if !isIntializing && level != oldValue {
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

    /// - Parameters:
    ///   - spaceId: the ID of the space being updated
    ///   - userId: the ID of the user whose space access will be modified
    ///   - level: the current/initial access level for this user to this space
    init(spaceId: String, userId: String, level: SpaceACLLevel) {
        self.spaceId = spaceId
        self.userId = userId
        self.level = level
        self.isIntializing = false
    }
}

/// Modifies whether the space is publicly viewable
class SpacePublicACLController: ObservableObject {
    /// Bind this to a `Toggle` or other input view, or manually assign a value.
    /// The space’s public status will be updated whenever its value is changed.
    @Published var hasPublicACL: Bool {
        didSet {
            if !isIntializing && hasPublicACL != oldValue {
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

    /// - Parameters:
    ///   - id: the ID of the space to update
    ///   - hasPublicACL: whether the space is currently public.
    init(id: String, hasPublicACL: Bool) {
        self.id = id
        self.hasPublicACL = hasPublicACL
        self.isIntializing = false
    }
}
