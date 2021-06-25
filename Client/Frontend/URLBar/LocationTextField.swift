// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

fileprivate enum LocationTextFieldUX {
    static let textFieldOffset: CGFloat = 200
}

struct LocationTextField: View {
    let currentUrl: URL?
    let onSubmit: (String) -> ()
    @Binding var textField: UITextField?

    @EnvironmentObject private var historyModel: HistorySuggestionModel
    @ObservedObject private var searchQuery = SearchQueryModel.shared
    @State private var textFieldOffset: CGFloat = LocationTextFieldUX.textFieldOffset

    var body: some View {
        let query = searchQuery.value
        let suggestion = historyModel.autocompleteSuggestion
        HStack(spacing: 0) {
            LocationTextFieldIcon(currentUrl: currentUrl)
                .frame(width: TabLocationViewUX.height)

            ZStack(alignment: .leading) {
                if searchQuery.isEmpty {
                    TabLocationViewUX.placeholder
                        .foregroundColor(.secondaryLabel)
                        .accessibilityHidden(true)
                        .transition(.identity)
                } else if
                    let query = query,
                    suggestion != query,
                    let range = suggestion.range(of: query),
                    range.lowerBound == suggestion.startIndex {
                    HStack(spacing: 0) {
                        Text(query)
                            .foregroundColor(.clear)
                        Text(suggestion[range.upperBound...])
                            .padding(.vertical, 1)
                            .padding(.trailing, 3)
                            .background(Color.textSelectionHighlight.cornerRadius(2, corners: .right))
                            .padding(.vertical, -1)
                    }.padding(.top, 1).animation(nil).transition(.identity)
                }
                TextField(
                    "",
                    text: Binding { searchQuery.value ?? "" } set: { searchQuery.value = $0 },
                    onCommit: {
                        if historyModel.autocompleteSuggestion.isEmpty {
                            onSubmit(searchQuery.value ?? "")
                        } else {
                            onSubmit(historyModel.autocompleteSuggestion)
                        }

                        searchQuery.value = nil
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

                        if !searchQuery.isEmpty {
                            tf.selectAll(nil)
                            tf.tintColor = .ui.adaptive.blue.withAlphaComponent(0)
                            tf.addAction(UIAction { _ in  }, for: .valueChanged)
                        }
                    }
                    textField = tf
                }
                .onChange(of: searchQuery.value) { newQuery in
                    textField?.tintColor = .ui.adaptive.blue
                    if let newQuery = newQuery,
                       let query = query,
                       let last = query.last,
                       newQuery + String(last) == query,
                       !suggestion.isEmpty {
                        historyModel.clearSuggestion()
                        historyModel.setQueryWithoutAutocomplete(query)
                    }
                }
                .onTapGesture {
                    textField?.tintColor = .ui.adaptive.blue
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
//    struct Preview: View {
//        @State var text: String?
//        let activeLensBang: ActiveLensBangInfo?
//
//        var body: some View {
//            LocationTextField(model: SuggestionModel(profile: profile), currentUrl: nil, activeLensBang: activeLensBang, onSubmit: { _ in }, textField: .constant(nil))
//        }
//    }
    static var previews: some View {
        Group {
//            Preview(text: "", activeLensBang: nil)
//            Preview(text: "hello, world", activeLensBang: nil)
//            Preview(text: "https://apple.com/", activeLensBang: nil)
//            Preview(text: "!w something", activeLensBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .bang))
//            Preview(text: "@w something", activeLensBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .lens))
        }
        .frame(height: TabLocationViewUX.height)
        .background(Capsule().fill(Color.systemFill))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
