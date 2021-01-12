//
//  Action.swift
//  
//
//  Created by Jed Fox on 1/11/21.
//

import SwiftUI

public struct Action: Identifiable {
    public let name: String
    public let icon: String
    public let handler: () -> ()

    public var id: String { name }

    public static func edit(condition: Bool = true, handler: @escaping () -> ()) -> Action? {
        Action("Edit", icon: "pencil", condition: condition, handler: handler)
    }
    public static func delete(condition: Bool = true, handler: @escaping () -> ()) -> Action? {
        Action("Delete", icon: "trash", condition: condition, handler: handler)
    }

    public init?(_ name: String, icon: String, condition: Bool = true, handler: @escaping () -> ()) {
        if condition {
            self.name = name
            self.icon = icon
            self.handler = handler
        } else {
            return nil
        }
    }

    public var view: some View {
        Button(action: handler) {
            Label(name, systemImage: icon)
        }
    }

    public func addTo<V: View>(_ view: V) -> some View {
        view.accessibilityAction(named: name, handler)
    }
}

extension View {
    @ViewBuilder public func accessibilityActions(_ actions: [Action?]) -> some View {
        if actions.isEmpty {
            self
        } else if let last = actions.last, let last_ = last {
            AnyView(last_.addTo(self.accessibilityActions(actions.dropLast())))
        } else {
            AnyView(self.accessibilityActions(actions.dropLast()))
        }
    }
}

extension Array: View where Element == Action? {
    public var body: some View {
        ForEach(self.compactMap { $0 }) { $0.view }
    }

    @ViewBuilder public var menu: some View {
        if !isEmpty {
            Menu {
                self
            } label: {
                Image(systemName: "ellipsis")
                    .imageScale(.large)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 5)
                    .contentShape(Rectangle())
            }.accentColor(.blue)
        }
    }
}
