import SwiftUI
import Combine
import NeevaSupport

class SuggestionsViewController: UIHostingController<SuggestionsView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: SuggestionsView())
    }
}

struct SuggestionsView: View {
    @ObservedObject var controller = SuggestionsController()
    @State var selectedSuggestion: Suggestion?
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter query", text: $controller.query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                List(controller.data ?? []) { suggestion in
                    SuggestionView(
                        suggestion,
                        setInput: { controller.query = $0 },
                        onTap: { selectedSuggestion = suggestion }
                    )
                }.alert(item: $selectedSuggestion) { (suggestion) -> Alert in
                    switch suggestion {
                    case .query(let query):
                        return Alert(title: Text("Tapped on “\(query.suggestedQuery)”"))
                    case .url(let url):
                        return Alert(title: Text("Tapped on “\(url.suggestedUrl)”"))
                    }
                }
            }.navigationBarTitle(Text("Suggestions"))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsView()
    }
}

