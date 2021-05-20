//
//  Action.swift
//  
//
//  Created by Jed Fox on 1/11/21.
//

import SwiftUI
import Shared

/// An action that’s able to be represented both as a button/menu item
/// and an accessibility action for VoiceOver users.
public struct Action: Identifiable {
    /// The display name of the string
    let name: String
    /// The SF Symbol name of the icon displayed next to the name
    let icon: String
    /// A function that performs the action
    let handler: () -> ()

    public var id: String { name }

    /// The standard “Edit” action
    static func edit(condition: Bool = true, handler: @escaping () -> ()) -> Action? {
        Action("Edit", icon: "pencil", condition: condition, handler: handler)
    }
    /// The standard “Delete” action
    static func delete(condition: Bool = true, handler: @escaping () -> ()) -> Action? {
        Action("Delete", icon: "trash", condition: condition, handler: handler)
    }

    /// - Parameters:
    ///   - name: the display name
    ///   - icon: the SF Symbol icon
    ///   - condition: convenience for actions which are only available in some cases
    ///   - handler: the function to call when the action is activated
    init?(_ name: String, icon: String, condition: Bool = true, handler: @escaping () -> ()) {
        if condition {
            self.name = name
            self.icon = icon
            self.handler = handler
        } else {
            return nil
        }
    }

    var view: some View {
        Button(action: handler) {
            Label(name, systemImage: icon)
        }
    }

    func addTo<V: View>(_ view: V) -> some View {
        view.accessibilityAction(named: name, handler)
    }
}

/// Use an array of `Action?` as a view, or access its `menu` property to create a pop-up menu
extension Array: View where Element == Action? {
    public var body: some View {
        ForEach(self.compactMap { $0 }) { $0.view }
    }

    @ViewBuilder var menu: some View {
        if !isEmpty {
            Menu {
                self
            } label: {
                Symbol(.ellipsis, label: "Actions")
                    .imageScale(.large)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 5)
                    .contentShape(Rectangle())
            }.accentColor(.blue)
        }
    }
}
