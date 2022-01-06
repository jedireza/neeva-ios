// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI

enum BrowserState {
    case tab
    case switcher
}

class BrowserModel: ObservableObject {
    @Published var currentState: BrowserState = .tab
}
