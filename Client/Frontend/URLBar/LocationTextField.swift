// Copyright Neeva. All rights reserved.

import SwiftUI

fileprivate enum LocationTextFieldUX {
    static let iconSize: CGFloat = 20
    static let textFieldOffset: CGFloat = 200
}

struct LocationTextField: View {
    @Binding var text: String?
    let onSubmit: (String) -> ()
    @Binding var textField: UITextField?

    @State var textFieldOffset: CGFloat = LocationTextFieldUX.textFieldOffset

    var body: some View {
        HStack(spacing: 0) {
            Image("neevaMenuIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: LocationTextFieldUX.iconSize, height: LocationTextFieldUX.iconSize)
                .frame(width: TabLocationViewUX.height)

            ZStack(alignment: .leading) {
                if text?.isEmpty ?? true {
                    TabLocationViewUX.placeholder
                        .foregroundColor(.secondaryLabel)
                        .accessibilityHidden(true)
                        .transition(.identity)
                }
                TextField(
                    "",
                    text: Binding { text ?? "" } set: { text = $0 },
                    onCommit: {
                        onSubmit(text ?? "")
                        text = nil
                    }
                )
                .keyboardType(.webSearch)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .accessibilityLabel("Address and Search")
                .introspectTextField { tf in
                    tf.enablesReturnKeyAutomatically = true
                    tf.returnKeyType = .go
                    tf.clearButtonMode = .whileEditing
                    if textField?.superview == nil {
                        // TODO: When dropping support for iOS 14, change this to use .focused()
                        tf.becomeFirstResponder()

                        if !(text?.isEmpty ?? true) {
                            tf.selectAll(nil)
                            tf.tintColor = .neeva.ui.blue.withAlphaComponent(0)
                            tf.addAction(UIAction { _ in  }, for: .valueChanged)
                        }
                    }
                    textField = tf
                }
                .onChange(of: text) { value in
                    textField?.tintColor = .neeva.ui.blue
                }
                .onTapGesture {
                    textField?.tintColor = .neeva.ui.blue
                }
            }
            .padding(.trailing, 6)
            .offset(x: textFieldOffset, y: 0)
            .onAppear {
                textFieldOffset = 0
            }
            .onDisappear {
                textFieldOffset = LocationTextFieldUX.textFieldOffset
                textField = nil
            }
        }
    }
}

struct LocationTextField_Previews: PreviewProvider {
    struct Preview: View {
        @State var text: String?
        var body: some View {
            LocationTextField(text: $text, onSubmit: { _ in }, textField: .constant(nil))
        }
    }
    static var previews: some View {
        Group {
            Preview(text: "")
            Preview(text: "hello, world")
            Preview(text: "https://apple.com/")
        }
        .frame(height: TabLocationViewUX.height)
        .background(Capsule().fill(Color.systemFill))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
