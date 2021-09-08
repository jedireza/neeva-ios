// Copyright Neeva. All rights reserved.

import Foundation

class SystemsHelper {
    static func openSystemSettingsNeevaPage() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
}
