//
//  SpaceInviteView.swift
//  
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI

struct SpaceInviteView: View {
    @Binding var invite: InviteState

    @ObservedObject var suggestions: ContactSuggestionController

    struct UserToken: View {
        let user: ContactSuggestionController.Suggestion
        let onRemove: () -> ()
        var body: some View {
            Menu {
                Button(action: onRemove) {
                    Label("Remove", systemImage: "trash")
                }
                Button(action: { UIPasteboard.general.string = user.email }) {
                    Label("Copy Email", systemImage: "doc.on.doc")
                }
            } label: {
                Text(user.displayName.isEmpty ? user.email : user.displayName)
                    .font(.footnote)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 2)
                    .background(Color.overlayBlue)
                    .cornerRadius(6)
            }
            .accessibilityLabel(user.displayName.isEmpty ? user.email.replacingOccurrences(of: ".", with: " dot ") : user.displayName)
            .accessibilityHint("will be invited")
            .accessibilityRemoveTraits(.isButton)
            .accessibilityAction(named: "Remove", onRemove)
            .accessibilityAction(named: "Copy Email") { UIPasteboard.general.string = user.email }
        }
    }

    func selectFirst() -> Bool {
        if case .success(let suggestions) = suggestions.state,
           let suggestion = suggestions.first {
            invite.selected.append(suggestion)
            self.suggestions.query = ""
            return false
        } else if !suggestions.query.isEmpty {
            invite.selected.append(.init(displayName: "", email: suggestions.query, pictureUrl: ""))
            suggestions.query = ""
            return false
        }
        return true
    }

    var body: some View {
        return Group {
            Section(header: Text("\nInvite others to collaborate")) {
                if invite.selected.isEmpty {
                    HStack {
                        EmailSearchField(text: $suggestions.query, onReturn: selectFirst)
                        ACLPicker(acl: $invite.shareType)
                            .accessibilitySortPriority(1)
                    }
                } else {
                    VStack {
                        HStack(alignment: .bottom) {
                            // ideally, this would lay out the tags horizontally, then break across lines as needed
                            // however I couldn’t get that layout to work and this is fine
                            VStack(alignment: .leading) {
                                ForEach(Array(invite.selected.enumerated()), id: \.element.id) { idx, user in
                                    UserToken(user: user, onRemove: { invite.selected.remove(at: idx) })
                                }
                            }
                            Spacer()
                            ACLPicker(acl: $invite.shareType)
                                .padding(.bottom, invite.selected.count > 1 ? 3 : 1)
                        }
                    }
                    EmailSearchField(text: $suggestions.query, onReturn: selectFirst)
                }
            }
        }
    }
}

struct EmailSearchField: UIViewRepresentable {
    @Binding var text: String
    let onReturn: () -> Bool

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textContentType = .emailAddress
        tf.placeholder = "Enter email address"
        tf.font = .preferredFont(forTextStyle: .body)
        tf.clearButtonMode = .whileEditing
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tf.delegate = context.coordinator
        tf.accessibilityTraits = [tf.accessibilityTraits, .searchField]
        return tf
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, onReturn: onReturn)
    }

    func updateUIView(_ tf: UITextField, context: Context) {
        if tf.text != text {
            tf.text = text
        }
        context.coordinator.onReturn = onReturn
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var onReturn: () -> Bool

        init(text: Binding<String>, onReturn: @escaping () -> Bool) {
            self.text = text
            self.onReturn = onReturn
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if onReturn() {
                textField.resignFirstResponder()
            }
            return false
        }
    }
}

struct SpaceInviteView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            HStack {
                SpaceInviteView.UserToken(user: .init(displayName: "Jed Fox", email: "...", pictureUrl: ""), onRemove: {})
                SpaceInviteView.UserToken(user: .init(displayName: "", email: "mail@example.com", pictureUrl: ""), onRemove: {})
            }
            SpaceInviteView(invite: .constant(InviteState()), suggestions: ContactSuggestionController())
        }
    }
}
