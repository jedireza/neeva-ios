// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import SwiftUI

public struct TabGroupContextMenu: View {
    let details: TabCardDetails
    public var body: some View {
        Button(action: {
            details.manager.get(for: details.id)?.isPinned.toggle()
        }) {
            details.manager.get(for: details.id)?.isPinned ?? false
                ? Label("Unpin tab", systemSymbol: .pinSlash) : Label("Pin tab", systemSymbol: .pin)
        }
    }
}
