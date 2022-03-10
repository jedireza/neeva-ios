// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Foundation

public class ProviderList: ObservableObject {
    public static let shared = ProviderList()

    @Published public private(set) var isLoading = false
    @Published public private(set) var allProviders: [String: UserPreference] = [:]
    @Published public private(set) var providerDisplayName: [String: String] = [:]

    public init() {}

    public func fetchProviderList() {
        // Todo remove Provider Related code because API is deprecated.
    }

    public func isListEmpty() -> Bool {
        return self.allProviders.count == 0
    }

    public func getPreferenceByDomain(domain: String) -> UserPreference {
        if allProviders.keys.contains(domain) {
            return allProviders[domain]!
        }

        fetchProviderList()
        return .noPreference
    }

    public func getDisplayName(for domain: String) -> String {
        if providerDisplayName.keys.contains(domain) {
            return providerDisplayName[domain]!
        }
        return domain
    }
}
