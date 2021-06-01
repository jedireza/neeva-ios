// Copyright © Neeva. All rights reserved.

import SwiftUI

// There’s no way to “weight” spacers (so that some take up more of the free space than others)
// so instead we just repeat the spacer multiple times. Hacky, but functional!
extension Spacer {
    func repeated(_ times: Int) -> some View {
        ForEach(0..<times) { _ in
            self
        }
    }
}

