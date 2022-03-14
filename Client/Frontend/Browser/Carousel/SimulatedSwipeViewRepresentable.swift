// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct SimulatedSwipeViewRepresentable: UIViewControllerRepresentable {
    let model: SimulatedSwipeModel
    let superview: UIView!

    func makeUIViewController(context: Context) -> SimulatedSwipeController {
        let simulatedSwipeController = SimulatedSwipeController(model: model, superview: superview)
        simulatedSwipeController.view.isHidden = true

        return simulatedSwipeController
    }

    func updateUIViewController(_ uiViewController: SimulatedSwipeController, context: Context) {
        // Nothing to do here
    }
}
