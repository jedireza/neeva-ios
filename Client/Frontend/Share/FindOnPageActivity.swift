//
//  FindOnPageActivity.swift
//  Neeva iOS
//
//  Created by Neeva on 10/03/21.
//  Copyright © 2021 Neeva Inc. All rights reserved.
//

import Foundation
import Shared

class FindOnPageActivity: UIActivity {
    fileprivate let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    override var activityTitle: String? {
        return Strings.AppMenuFindInPageTitleString
    }

    override var activityImage: UIImage? {
        return #imageLiteral(resourceName: "search")
    }

    override func perform() {
        callback()
        activityDidFinish(true)
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
}
