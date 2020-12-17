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
    var body: some View {
        VStack {
            TextField("Enter query", text: $controller.query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            List(controller.suggestions) { suggestion in
                SuggestionView(suggestion, setInput: { controller.query = $0 })
            }
        }
    }
}

struct SuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsView()
    }
}

