// Copyright © 2021 Neeva. All rights reserved.

import SwiftUI

/// A custom `TextField` that matches our style — a rounded, gray background with slightly darker placeholder text than normal. We also add a clear button.
/// TODO: make this into a `TextFieldStyle` when that becomes possible
public struct CapsuleTextField<Icon: View>: View {
    private let onEditingChanged: ((Bool) -> ())?

    let icon: Icon?
    let placeholder: String
    @Binding var text: String
    var detailText: String?

    @State private var textFieldWidth: CGFloat = 0
    private let alwaysShowClearButton: Bool
    private var showClearButton: Bool {
        if !alwaysShowClearButton {
            // about the maximum number of characters before the textfield "scrolls"
            return text.size(withAttributes: [.font: FontStyle.bodyMedium.getUIFont(for: textFieldSizeCategory)]).width > textFieldWidth - 5
        } else {
            return true
        }
    }

    let focusTextField: Bool
    @State private var focusedTextField = false
    @State private var isEditing = false

    @Environment(\.sizeCategory) var textFieldSizeCategory

    public init(icon: Icon, placeholder: String, text: Binding<String>, alwaysShowClearButton: Bool = true, detailText: String? = nil, focusTextField: Bool = false, onEditingChanged: ((Bool) -> ())? = nil) {
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
        self.detailText = detailText

        self.alwaysShowClearButton = alwaysShowClearButton
        self.focusTextField = focusTextField
        self.onEditingChanged = onEditingChanged
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                icon.foregroundColor(.secondaryLabel)
            }

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder).withFont(.bodyMedium).foregroundColor(.secondaryLabel)
                        .accessibilityHidden(true)
                }

                TextField("", text: $text, onEditingChanged: { editing in
                    isEditing = editing
                    onEditingChanged?(editing)

                    if editing && focusTextField {
                        focusedTextField = false
                    }
                })
                .accessibilityLabel(placeholder)
                .withFont(unkerned: .bodyMedium)
                .introspectTextField { textField in
                    if focusTextField && !focusedTextField {
                        focusedTextField = true

                        textField.becomeFirstResponder()
                        textField.selectAll(nil)
                    }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onChange(of: geo.size.width) { _ in
                                textFieldWidth = geo.size.width
                            }
                    }
                )
            }

            if isEditing && !text.isEmpty && showClearButton {
                Button(action: { text = "" }) {
                    Symbol(.xmarkCircleFill, label: "Clear")
                }
                .accentColor(.tertiaryLabel)
                .padding(.horizontal, 2)
            }

            if let detailText = detailText, !showClearButton {
                Text(detailText)
                    .foregroundColor(.secondaryLabel)
                    .padding(.trailing, 2)
                    .accessibilityIdentifier("Overlay_Text-Field_Detail_Text")
            }
        }
        .font(.system(size: 14))
        .padding(10)
        .padding(.leading, 7)
        .background(Capsule().fill(Color.tertiarySystemFill))
    }
}

extension CapsuleTextField where Icon == Never {
    init(_ placeholder: String, text: Binding<String>, alwaysShowClearButton: Bool = true, detailText: String? = nil, focusTextField: Bool = false, onEditingChanged: ((Bool) -> ())? = nil) {
        self.icon = nil
        self.placeholder = placeholder
        self._text = text
        self.detailText = detailText

        self.alwaysShowClearButton = alwaysShowClearButton
        self.focusTextField = focusTextField
        self.onEditingChanged = onEditingChanged
    }
}

struct PlaceholderField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CapsuleTextField("Placeholder", text: .constant(""))
            CapsuleTextField("Placeholder", text: .constant("Hello, world!"))
            CapsuleTextField("Placeholder", text: .constant("Hello, world!"), detailText: "Text")
            CapsuleTextField(icon: Symbol(decorative: .starFill), placeholder: "Placeholder", text: .constant(""))
            CapsuleTextField(icon: Symbol(decorative: .starFill), placeholder: "Placeholder", text: .constant("Hello, world!"))
        }.padding().previewLayout(.sizeThatFits)
    }
}
