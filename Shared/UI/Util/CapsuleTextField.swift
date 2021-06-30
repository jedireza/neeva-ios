// Copyright © 2021 Neeva. All rights reserved.

import SwiftUI

/// A custom `TextField` that matches our style — a rounded, gray background with slightly darker placeholder text than normal. We also add a clear button.
/// TODO: make this into a `TextFieldStyle` when that becomes possible
struct CapsuleTextField<Icon: View>: View {
    let placeholder: String
    @Binding var text: String
    let icon: Icon?

    @State private var isEditing = false

    init(_ placeholder: String, text: Binding<String>, icon: Icon) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                icon.foregroundColor(.secondaryLabel)
            }
            ZStack(alignment: .leading) {
                if text.isEmpty { Text(placeholder).withFont(.bodyMedium).foregroundColor(.secondaryLabel).accessibilityHidden(true) }
                TextField("", text: $text, onEditingChanged: { isEditing = $0 }).accessibilityLabel(placeholder)
                    .withFont(unkerned: .bodyMedium)
            }
            if isEditing && !text.isEmpty {
                Button(action: { text = "" }) {
                    Symbol(.xmarkCircleFill, label: "Clear")
                }
                .accentColor(.tertiaryLabel)
                .padding(.horizontal, 2)
            }
        }
        .font(.system(size: 14))
        .padding(10)
        .padding(.leading, 7)
        .background(Capsule().fill(Color.tertiarySystemFill))
    }
}

extension CapsuleTextField where Icon == Never {
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
        self.icon = nil
    }
}

struct PlaceholderField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CapsuleTextField("Placeholder", text: .constant(""))
            CapsuleTextField("Placeholder", text: .constant("Hello, world!"))
            CapsuleTextField("Placeholder", text: .constant(""), icon: Symbol(.starFill))
            CapsuleTextField("Placeholder", text: .constant("Hello, world!"), icon: Symbol(.starFill))
        }.padding().previewLayout(.sizeThatFits)
    }
}
