// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

public enum OpenSysSettingTrigger: String {
    case defaultBrowserPrompt
    case defaultBrowserPromoCard
    case defaultBrowserPromptDirect
    case settings
}

extension UIApplication {

    func openSettings(triggerFrom: OpenSysSettingTrigger, sourceView: String? = nil) {
        ClientLogger.shared.logCounter(
            .GoToSysAppSettings,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.UIInteractionAttribute.openSysSettingSourceView,
                    value: String(describing: sourceView)
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.UIInteractionAttribute.openSysSettingTriggerFrom,
                    value: triggerFrom.rawValue
                ),
            ]
        )
        self.open(
            URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }
}
