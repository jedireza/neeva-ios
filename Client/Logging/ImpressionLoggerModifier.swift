// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import SwiftUI

private let defaultTimeInterval: TimeInterval = 2

struct ImpressionLoggerModifier: ViewModifier {
    @State var impressionTimer: Timer? = nil

    let timeInterval: TimeInterval
    let path: LogConfig.Interaction
    let attributes: [ClientLogCounterAttribute]

    init(
        timeInterval: TimeInterval = defaultTimeInterval,
        path: LogConfig.Interaction,
        attributes: [ClientLogCounterAttribute] = []
    ) {
        self.timeInterval = timeInterval
        self.path = path
        self.attributes = attributes
    }

    func startImpressionTimer() {
        impressionTimer?.invalidate()
        impressionTimer = Timer.scheduledTimer(
            withTimeInterval: timeInterval,
            repeats: false
        ) { _ in
            ClientLogger.shared.logCounter(path, attributes: attributes)
        }
    }

    func resetImpressionTimer() {
        impressionTimer?.invalidate()
        impressionTimer = nil
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                startImpressionTimer()
            }
            .onDisappear {
                resetImpressionTimer()
            }
    }
}
