// Copyright Neeva. All rights reserved.

import SwiftUI

extension EnvironmentValues {
    private struct OpenInNewTabKey: EnvironmentKey {
        static var defaultValue: ((URL, _ isPrivate: Bool) -> Void)? = nil
    }
    public var openInNewTab: (URL, _ isPrivate: Bool) -> Void {
        get {
            self[OpenInNewTabKey.self] ?? { _, _ in
                fatalError(".environment(\\.openInNewTab) must be specified")
            }
        }
        set { self[OpenInNewTabKey.self] = newValue }
    }

    // UIView here is used as a target view to anchor the share pop over on iPad.
    private struct ShareURLKey: EnvironmentKey {
        static var defaultValue: ((URL, UIView) -> Void)? = nil
    }
    public var shareURL: (URL, UIView) -> Void {
        get {
            self[ShareURLKey.self] ?? { _, _ in
                fatalError(".environment(\\.shareURL) must be specified")
            }
        }
        set { self[ShareURLKey.self] = newValue }
    }

    private struct SetSearchInputKey: EnvironmentKey {
        static var defaultValue: ((String) -> Void)? = nil
    }
    public var setSearchInput: (String) -> Void {
        get {
            self[SetSearchInputKey.self] ?? { _ in
                fatalError(".environment(\\.setSearchInput) must be specified")
            }
        }
        set { self[SetSearchInputKey.self] = newValue }
    }

    private struct IsIncognitoKey: EnvironmentKey {
        static var defaultValue = false
    }
    public var isIncognito: Bool {
        get { self[IsIncognitoKey.self] }
        set { self[IsIncognitoKey.self] = newValue }
    }

    private struct SuggestionConfigKey: EnvironmentKey {
        static var defaultValue = SuggestionConfig.row
    }
    /// Determines whether to display suggestions as rows or chips
    public var suggestionConfig: SuggestionConfig {
        get { self[SuggestionConfigKey.self] }
        set { self[SuggestionConfigKey.self] = newValue }
    }

    private struct SaveToSpaceKey: EnvironmentKey {
        static var defaultValue: ((URL, _ description: String?, _ title: String?) -> Void)? = nil
    }
    public var saveToSpace: (URL, _ description: String?, _ title: String?) -> Void {
        get {
            self[SaveToSpaceKey.self] ?? { _, _, _ in
                fatalError(".environment(\\.saveToSpace) must be specified")
            }
        }
        set { self[SaveToSpaceKey.self] = newValue }
    }
}
