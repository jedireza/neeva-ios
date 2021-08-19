// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import SwiftUI

public struct ZeroQueryCommonContextMenuActions: View {
    let siteURL: URL
    let title: String?
    let description: String?

    @Environment(\.openInNewTab) private var openInNewTab
    @Environment(\.shareURL) private var shareURL
    @Environment(\.saveToSpace) private var saveToSpace

    public var body: some View {
        Button(action: { openInNewTab(siteURL, false) }) {
            Label("Open in New Tab", systemSymbol: .plusSquare)
        }
        Button(action: { openInNewTab(siteURL, true) }) {
            Label {
                Text("Open in Incognito")
            } icon: {
                Image("incognito").renderingMode(.template)
            }
        }
        Button(action: { saveToSpace(siteURL, title, description) }) {
            Label("Save to Spaces", systemSymbol: .bookmark)
        }
        Button(action: { shareURL(siteURL) }) {
            Label("Share", systemSymbol: .squareAndArrowUp)
        }

    }
}
