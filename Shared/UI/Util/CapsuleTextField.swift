// Copyright © 2021 Neeva. All rights reserved.

import SwiftUI

/// A custom `TextField` that matches our style — a rounded, gray background with slightly darker placeholder text than normal. We also add a clear button.
/// TODO: make this into a `TextFieldStyle` when that becomes possible
public struct CapsuleTextField<Icon: View>: View {
    private let onEditingChanged: ((Bool) -> Void)?

    let icon: Icon?
    let placeholder: String
    @Binding var text: String
    var detailText: String?

    @State private var textFieldWidth: CGFloat = 0
    private let alwaysShowClearButton: Bool
    private var showClearButton: Bool {
        if !alwaysShowClearButton {
            // about the maximum number of characters before the textfield "scrolls"
            return
                text.size(withAttributes: [
                    .font: FontStyle.bodyMedium.uiFont(for: textFieldSizeCategory)
                ]).width > textFieldWidth - 5
        } else {
            return true
        }
    }

    let focusTextField: Bool
    @State private var focusedTextField = false
    @State private var isEditing = false

    var secureText: Bool

    @Binding var errorMessage: String

    @Environment(\.sizeCategory) var textFieldSizeCategory

    @ViewBuilder
    var textField: some View {
        if secureText {
            SecureField("", text: $text) {
                isEditing = false
                onEditingChanged?(isEditing)
            }
            .onTapGesture {
                isEditing = true
                onEditingChanged?(isEditing)

                errorMessage = ""

                if focusTextField {
                    focusedTextField = false
                }
            }
        } else {
            TextField(
                "", text: $text,
                onEditingChanged: { editing in
                    isEditing = editing
                    onEditingChanged?(editing)

                    errorMessage = ""

                    if editing && focusTextField {
                        focusedTextField = false
                    }
                }
            )
        }
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                icon.foregroundColor(.secondaryLabel)
            }

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    if !errorMessage.isEmpty {
                        Text(errorMessage).withFont(.bodyMedium).foregroundColor(.red)
                            .accessibilityHidden(true)
                    } else {
                        Text(placeholder).withFont(.bodyMedium).foregroundColor(.secondaryLabel)
                            .accessibilityHidden(true)
                    }
                }

                textField
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

    public init(
        icon: Icon, placeholder: String,
        text: Binding<String>,
        errorMessage: Binding<String> = .constant(""),
        alwaysShowClearButton: Bool = true,
        detailText: String? = nil,
        focusTextField: Bool = false,
        secureText: Bool = false,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
        self._errorMessage = errorMessage
        self.detailText = detailText

        self.alwaysShowClearButton = alwaysShowClearButton
        self.focusTextField = focusTextField
        self.secureText = secureText

        self.onEditingChanged = onEditingChanged
    }
}

extension CapsuleTextField where Icon == Never {
    init(
        _ placeholder: String,
        text: Binding<String>,
        errorMessage: Binding<String> = .constant(""),
        alwaysShowClearButton: Bool = true,
        detailText: String? = nil,
        focusTextField: Bool = false,
        secureText: Bool = false,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self.icon = nil
        self.placeholder = placeholder
        self._text = text
        self._errorMessage = errorMessage
        self.detailText = detailText

        self.alwaysShowClearButton = alwaysShowClearButton
        self.focusTextField = focusTextField
        self.secureText = secureText

        self.onEditingChanged = onEditingChanged
    }
}

struct PlaceholderField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CapsuleTextField("Placeholder", text: .constant(""))
            CapsuleTextField("Placeholder", text: .constant("Hello, world!"))
            CapsuleTextField("Placeholder", text: .constant("Hello, world!"), detailText: "Text")
            CapsuleTextField(
                icon: Symbol(decorative: .starFill), placeholder: "Placeholder", text: .constant("")
            )
            CapsuleTextField(
                icon: Symbol(decorative: .starFill), placeholder: "Placeholder",
                text: .constant("Hello, world!"))
        }.padding().previewLayout(.sizeThatFits)
    }
}
