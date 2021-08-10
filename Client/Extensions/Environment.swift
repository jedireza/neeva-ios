// Copyright Neeva. All rights reserved.

import SwiftUI

extension EnvironmentValues {
    private struct ViewWidthKey: EnvironmentKey {
        static let defaultValue: CGFloat = 0
    }
    var viewWidth: CGFloat {
        get { self[ViewWidthKey.self] }
        set { self[ViewWidthKey.self] = newValue }
    }

    private struct OpenInNewTabKey: EnvironmentKey {
        static var defaultValue: ((URL, _ isPrivate: Bool) -> Void)? = nil
    }

    public var openInNewTab: (URL, _ isPrivate: Bool) -> Void {
        get {
            self[OpenInNewTabKey] ?? { _, _ in
                fatalError(".environment(\\.openInNewTab) must be specified")
            }
        }
        set { self[OpenInNewTabKey] = newValue }
    }

    private struct ShareURLKey: EnvironmentKey {
        static var defaultValue: ((URL) -> Void)? = nil
    }

    public var shareURL: (URL) -> Void {
        get {
            self[ShareURLKey] ?? { _ in fatalError(".environment(\\.shareURL) must be specified") }
        }
        set { self[ShareURLKey] = newValue }
    }

    private struct SetSearchInputKey: EnvironmentKey {
        static var defaultValue: ((String) -> Void)? = nil
    }

    public var setSearchInput: (String) -> Void {
        get {
            self[SetSearchInputKey] ?? { _ in
                fatalError(".environment(\\.setSearchInput) must be specified")
            }
        }
        set { self[SetSearchInputKey] = newValue }
    }

    private struct IsIncognitoKey: EnvironmentKey {
        static var defaultValue = false
    }

    public var isIncognito: Bool {
        get { self[IsIncognitoKey] }
        set { self[IsIncognitoKey] = newValue }
    }

    private struct suggestionConfigKey: EnvironmentKey {
        static var defaultValue = SuggestionConfig.row
    }

    public var suggestionConfig: SuggestionConfig {
        get { self[suggestionConfigKey] }
        set { self[suggestionConfigKey] = newValue }
    }

    private struct SaveToSpaceKey: EnvironmentKey {
        static var defaultValue: ((URL, _ description: String?, _ title: String?) -> Void)? = nil
    }

    public var saveToSpace: (URL, _ description: String?, _ title: String?) -> Void {
        get {
            self[SaveToSpaceKey] ?? { _, _, _ in
                fatalError(".environment(\\.saveToSpace) must be specified")
            }
        }
        set { self[SaveToSpaceKey] = newValue }
    }
}
