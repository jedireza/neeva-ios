// Copyright Neeva. All rights reserved.

import Foundation

public class CheatsheetInfo: ObservableObject {
    public static let shared = CheatsheetInfo()

    @Published public private(set) var cheatsheetData: CheatsheetQueryController.CheatsheetInfo?
    @Published public private(set) var currentURL: String?

    public init() {
        self.cheatsheetData = nil
        self.currentURL = nil
    }

    public func hasCheatsheetInfo() -> Bool {
        return self.cheatsheetData != nil
    }

    public func fetch(url: URL) {
        self.cheatsheetData = nil
        // return if it is neeva url or not https protocol
        if url.host == NeevaConstants.appHost || url.scheme != "https" {
            return
        }
        self.currentURL = url.absoluteString
        CheatsheetQueryController.getCheatsheetInfo(url: url.absoluteString) { result in
            switch result {
            case .success(let cheatsheetInfo):
                self.cheatsheetData = cheatsheetInfo[0]
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
