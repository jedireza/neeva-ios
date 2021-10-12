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
            reviews: nil
        )

    init(tabManager: TabManager) {
        if let url = tabManager.selectedTab?.url?.absoluteString {
            setupRecipeData(url: url)
        }
    }

    public func updateContentWithURL(url: String) {
        // reset before getting new data
        self.recipe = Recipe(
            title: "",
            imageURL: "",
            totalTime: nil,
            prepTime: nil,
            yield: nil,
            ingredients: nil,
            instructions: nil,
            recipeRating: nil,
            reviews: nil
        )
        setupRecipeData(url: url)
    }

    private func setupRecipeData(url: String) {
        CheatsheetQueryController.getCheatsheetInfo(url: url) { result in
            switch result {
            case .success(let cheatsheetInfo):
                let data = cheatsheetInfo[0]
                if data.recipe != nil {
                    self.recipe = data.recipe!
                }
            case .failure(_):
                break
            }

        }
    }
}
