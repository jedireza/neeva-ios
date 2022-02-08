// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

enum CardTransitionState {
    case hidden
    case visibleForTrayShow
    case visibleForTrayHidden
}

class CardTransitionModel: ObservableObject {
    @Published var state = CardTransitionState.hidden
}
