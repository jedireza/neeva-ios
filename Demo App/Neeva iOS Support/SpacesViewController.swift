import SwiftUI
import Combine
import NeevaSupport

class SpacesViewController: UIHostingController<SpaceListView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: SpaceListView())
    }
}
