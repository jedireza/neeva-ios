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
        static var defaultValue: ((URL, _ isPrivate: Bool) -> ())? = nil
    }

    public var openInNewTab: (URL, _ isPrivate: Bool) -> () {
        get { self[OpenInNewTabKey] ?? { _,_ in fatalError(".environment(\\.openInNewTab) must be specified") } }
        set { self[OpenInNewTabKey] = newValue }
    }

    private struct ShareURLKey: EnvironmentKey {
        static var defaultValue: ((URL) -> ())? = nil
    }

    public var shareURL: (URL) -> () {
        get { self[ShareURLKey] ?? { _ in fatalError(".environment(\\.shareURL) must be specified") } }
        set { self[ShareURLKey] = newValue }
    }

    private struct SetSearchInputKey: EnvironmentKey {
        static var defaultValue: ((String) -> ())? = nil
    }

    public var setSearchInput: (String) -> () {
        get { self[SetSearchInputKey] ?? { _ in fatalError(".environment(\\.setSearchInput) must be specified") } }
        set { self[SetSearchInputKey] = newValue }
    }

    private struct IsIncognitoKey: EnvironmentKey {
        static var defaultValue = false
    }

    public var isIncognito: Bool {
        get { self[IsIncognitoKey] }
        set { self[IsIncognitoKey] = newValue }
    }
}
