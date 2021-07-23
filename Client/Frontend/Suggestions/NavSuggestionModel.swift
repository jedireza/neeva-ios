// Copyright Neeva. All rights reserved.

import Combine
import Apollo
import Shared
import Defaults
import Storage

class NavSuggestionModel: ObservableObject {
    @Published private var recentNavSuggestions: [NavSuggestion] = []
    @Published private var neevaNavSuggestions: [NavSuggestion] = []
    @Published private var historyNavSuggestions: [NavSuggestion] = []
    
    var combinedSuggestions: [NavSuggestion] = []
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(neevaModel: NeevaSuggestionModel,
         historyModel: HistorySuggestionModel) {
        historyModel.$recentSites.sink { [unowned self] sites in
            recentNavSuggestions = sites?.compactMap{NavSuggestion(site: $0)} ?? []
        }.store(in: &subscriptions)
        
        historyModel.$sites.sink { [unowned self] sites in
            historyNavSuggestions = sites?.compactMap{NavSuggestion(site: $0)} ?? []
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
        
        Publishers.MergeMany($recentNavSuggestions, $historyNavSuggestions, $neevaNavSuggestions).sink { [unowned self] suggestions in
            combinedSuggestions = (recentNavSuggestions + neevaNavSuggestions + historyNavSuggestions).removeDuplicates()
        }.store(in: &subscriptions)
    }
}
