// Copyright Neeva. All rights reserved.

import Apollo
import Combine
import Defaults
import Shared
import Storage

class NavSuggestionModel: ObservableObject {

    static let numOfDisplayNavSuggestions = 5

    @Published private var recentNavSuggestions: [NavSuggestion] = []
    @Published private var neevaNavSuggestions: [NavSuggestion] = []
    @Published private var historyNavSuggestions: [NavSuggestion] = []

    var combinedSuggestions: [Suggestion] = []

    private var subscriptions: Set<AnyCancellable> = []

    init(
        neevaModel: NeevaSuggestionModel,
        historyModel: HistorySuggestionModel
    ) {
        historyModel.$recentSites.sink { [unowned self] sites in
            recentNavSuggestions = sites?.compactMap { NavSuggestion(site: $0) } ?? []
        }.store(in: &subscriptions)

        historyModel.$sites.sink { [unowned self] sites in
            historyNavSuggestions = sites?.compactMap { NavSuggestion(site: $0) } ?? []
        }.store(in: &subscriptions)

        neevaModel.$navSuggestions.sink { [unowned self] suggestions in
            neevaNavSuggestions = suggestions.compactMap {
                switch $0 {
                case .url(let suggestion): return NavSuggestion(suggestion: suggestion)
                default: return nil
                }
            }
        }
        .store(in: &subscriptions)

        Publishers.MergeMany($recentNavSuggestions, $historyNavSuggestions, $neevaNavSuggestions)
            .sink { [unowned self] suggestions in
                combinedSuggestions =
                    Array(
                        (recentNavSuggestions + neevaNavSuggestions + historyNavSuggestions)
                            .removeDuplicates().map { Suggestion.navigation($0) }
                            .prefix(NavSuggestionModel.numOfDisplayNavSuggestions))
            }.store(in: &subscriptions)
    }
}
