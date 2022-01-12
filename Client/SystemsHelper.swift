// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
