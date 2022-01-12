// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public enum RecipeCheatsheetLogType: String {
    case impression
    case clickRecipeBanner
    case clickShowMoreRecipe
    case clickPreferredProvider
    case updatePreferredProvider
}

public class RecipeCheatsheetLogManager {
    public var impressionUUIDAndURL: Set = Set<String>()
    public var clickRecipeBannerUUIDAndURL: Set = Set<String>()
    public var clickShowMoreRecipeUUIDAndURL: Set = Set<String>()
    public var clickPreferredProviderUUIDAndURL: Set = Set<String>()
    public var updatePreferredProviderUUIDAndURL: Set = Set<String>()

    public static let shared = RecipeCheatsheetLogManager()

    public func logInteraction(logType: RecipeCheatsheetLogType, tabUUIDAndURL: String) {
        switch logType {
        case .impression:
            if !impressionUUIDAndURL.contains(tabUUIDAndURL) {
                impressionUUIDAndURL.insert(tabUUIDAndURL)
                ClientLogger.shared.logCounter(
                    .RecipeCheatsheetImpression,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        case .clickRecipeBanner:
            if !clickRecipeBannerUUIDAndURL.contains(tabUUIDAndURL) {
                clickRecipeBannerUUIDAndURL.insert(tabUUIDAndURL)
                ClientLogger.shared.logCounter(
                    .RecipeCheatsheetClickBanner,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        case .clickShowMoreRecipe:
            if !clickShowMoreRecipeUUIDAndURL.contains(tabUUIDAndURL) {
                clickShowMoreRecipeUUIDAndURL.insert(tabUUIDAndURL)
                ClientLogger.shared.logCounter(
                    .RecipeCheatsheetShowMoreRecipe,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        case .clickPreferredProvider:
            if !clickPreferredProviderUUIDAndURL.contains(tabUUIDAndURL) {
                clickPreferredProviderUUIDAndURL.insert(tabUUIDAndURL)
                ClientLogger.shared.logCounter(
                    .RecipeCheatsheetClickPreferredProvider,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        case .updatePreferredProvider:
            if !updatePreferredProviderUUIDAndURL.contains(tabUUIDAndURL) {
                updatePreferredProviderUUIDAndURL.insert(tabUUIDAndURL)
                ClientLogger.shared.logCounter(
                    .RecipeCheatsheetUpdatePreferredProvider,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        }
    }

}
