import SwiftUI
import Combine
import NeevaSupport

class SpacesViewController: UIHostingController<SpacesView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: SpacesView())
    }
}

struct SpacesView: View {
    @ObservedObject var controller = SpaceListController()
    @State var selectedSpace: Space?
    var body: some View {
        NavigationView {
            List(controller.data ?? []) { space in
                Button(action: { self.selectedSpace = space }) {
                    SpaceView(space)
                }
            }.alert(item: $selectedSpace) { space in
                Alert(title: Text("Tapped on “\(space.space!.name!)”"))
            }.navigationBarTitle(Text("Spaces"))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SpacesView_Previews: PreviewProvider {
    static var previews: some View {
        SpacesView()
    }
}

