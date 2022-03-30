// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

struct TabGroup {
    var children: [Tab]
    var id: String

    var inferredTitle: String? {
        if let spaceID = children.first?.parentSpaceID, spaceID == children.first?.rootUUID {
            if let spaceTitle = SpaceStore.shared.get(for: spaceID)?.displayTitle {
                return spaceTitle
            } else if FeatureFlag[.enableCryptoWallet] && spaceID == Defaults[.cryptoPublicKey] {
                return "Your NFTs"
            }
        }
        return children.first?.displayTitle
    }

    var displayTitle: String {
        inferredTitle ?? "\(children.count) Tabs"
    }
}
