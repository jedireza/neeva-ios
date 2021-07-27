// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Foundation

public struct ZeroQueryCommonContextMenuActions: View{
    let siteURL: URL
    
    @Environment(\.openInNewTab) private var openInNewTab
    @Environment(\.shareURL) private var shareURL
    
    public var body: some View{
        Button(action: { openInNewTab(siteURL, false) } ) {
            Label("Open in New Tab", systemSymbol: .plusSquare)
        }
        Button(action: { openInNewTab(siteURL, true) } ) {
            Label("Open in Incognito", image: "incognito")
        }
        Button(action: { shareURL(siteURL) } ) {
            Label("Share", systemSymbol: .squareAndArrowUp)
        }
        
    }
}
