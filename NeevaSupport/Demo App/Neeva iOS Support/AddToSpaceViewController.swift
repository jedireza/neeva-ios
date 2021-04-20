import SwiftUI
import Combine
import NeevaSupport

class AddToSpaceDemoViewController: UIHostingController<AddToSpaceDemoView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: AddToSpaceDemoView())
    }
}

@ViewBuilder func LabelledField(_ title: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 5) {
        Text(title).fontWeight(.semibold)
        TextField(title, text: text)
    }.padding(.vertical, 5)
}

struct AddToSpaceSheetView: View {
    @StateObject var request: AddToSpaceRequest
    let onDismiss: () -> ()

    var body: some View {
        switch request.state {
        case .initial:
            AddToSpaceView(request: request)
        case .creatingSpace, .savingToSpace:
            LoadingView("Saving...")
        case .savedToSpace:
            Color.clear.onAppear { self.onDismiss() }
        case .failed:
            ErrorView(request.error!, in: self)
        }
    }
}

struct AddToSpaceDemoView: View {
    @State var title = "Example website"
    @State var description = "Hello, world!"
    @State var url = "https://example.com"

    @State var selectedSpace: String? = nil
    @State var addingToSpace = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    LabelledField("Title", text: $title)
                    LabelledField("Description", text: $description)
                    LabelledField("URL (required)", text: $url)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                }
                Section {
                    Button("Add to Space") {
                        self.addingToSpace = true
                    }
                }
                if let selectedSpace = selectedSpace {
                    Section {
                        Button("Selected space ID: \(selectedSpace) (tap to copy)") {
                            UIPasteboard.general.string = selectedSpace
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Add to Space"))
        }.navigationViewStyle(StackNavigationViewStyle())
        .onTapGesture {
            // Hide virtual keyboard if the user taps outside an editable field.
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .sheet(isPresented: $addingToSpace) {
            AddToSpaceSheetView(request: AddToSpaceRequest(title: title, description: description, url: URL(string: url)!)) {
                addingToSpace = false
            }
        }
    }
}

struct AddToSpaceDemoView_Previews: PreviewProvider {
    static var previews: some View {
        AddToSpaceDemoView()
    }
}
