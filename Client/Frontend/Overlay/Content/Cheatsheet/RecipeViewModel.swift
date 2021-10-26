// Copyright Neeva. All rights reserved.

import Foundation
import Shared

class RecipeViewModel: ObservableObject {
    @Published var recipe: Recipe =
        Recipe(
            title: "",
            imageURL: "",
            totalTime: nil,
            prepTime: nil,
            yield: nil,
            ingredients: nil,
            instructions: nil,
            recipeRating: nil,
            reviews: nil,
            preference: .noPreference
        )

    init(tabManager: TabManager) {
        if let url = tabManager.selectedTab?.url?.absoluteString {
            setupRecipeData(url: url)
        }
    }

    public func updateContentWithURL(url: URL) {
        if let host = url.host, let baseDomain = url.baseDomain {
            if DomainAllowList.recipeDomains[host] ?? false
                || DomainAllowList.recipeDomains[baseDomain] ?? false
            {
                setupRecipeData(url: url.absoluteString)
            } else {
                self.reset()
            }
        } else {
            self.reset()
        }
    }

    private func reset() {
        self.recipe = Recipe(
            title: "",
            imageURL: "",
            totalTime: nil,
            prepTime: nil,
            yield: nil,
            ingredients: nil,
            instructions: nil,
            recipeRating: nil,
            reviews: nil,
            preference: .noPreference
        )
    }

    private func setupRecipeData(url: String) {
        GraphQLAPI.shared.isAnonymous = true
        CheatsheetQueryController.getCheatsheetInfo(url: url) { result in
            switch result {
            case .success(let cheatsheetInfo):
                let data = cheatsheetInfo[0]
                if data.recipe != nil {
                    self.recipe = data.recipe!
                }
                break
            case .failure(_):
                self.reset()
                break
            }

        }
        GraphQLAPI.shared.isAnonymous = false
    }
}
