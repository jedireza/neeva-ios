// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI

/// Note: you **must** define any methods you want to be accessible using `@Action` with `private(set) lazy var` instead of `func`
protocol ActionProvider {}

extension View {
    func provideActions(_ actions: ActionProvider...) -> some View {
        environment(\.actions, Dictionary(uniqueKeysWithValues: actions.map { ("\(type(of: $0))", $0) }))
    }
}

@propertyWrapper struct ActionObject<Actions: ActionProvider>: DynamicProperty {
    @Environment(\.actions) private var actions

    var wrappedValue: Actions {
        guard let result = actions["\(Actions.self)"] as? Actions else {
            fatalError("Failed to find ActionObject for key \(Actions.self)")
        }
        return result
    }
}

@propertyWrapper struct Action<Actions: ActionProvider, Value>: DynamicProperty {
    @ActionObject private var object: Actions

    private let keyPath: KeyPath<Actions, Value>
    init(_ keyPath: KeyPath<Actions, Value>) {
        self.keyPath = keyPath
    }
    var wrappedValue: Value { object[keyPath: keyPath] }
}

extension EnvironmentValues {
    private struct ActionsKey: EnvironmentKey {
        static var defaultValue: [String: ActionProvider] = [:]
    }
    fileprivate var actions: [String: ActionProvider] {
        get { self[ActionsKey.self] }
        set { self[ActionsKey.self] = newValue }
    }
}
