// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

// There’s no way to “weight” spacers (so that some take up more of the free space than others)
// so instead we just repeat the spacer multiple times. Hacky, but functional!
extension Spacer {
    public func repeated(_ times: Int) -> some View {
        ForEach(0..<times, id: \.self) { _ in
            self
        }
    }
}
