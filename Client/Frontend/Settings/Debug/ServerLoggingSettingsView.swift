// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

struct ServerLoggingSettingsView: View {
    @State private var showingAlert = false

    let debugLoggerHistory = ClientLogger.shared.debugLoggerHistory

    var body: some View {
        List {
            ForEach(0..<debugLoggerHistory.count) { i in
                VStack(alignment: .leading) {
                    if #available(iOS 15.0, *) {
                        Button(debugLoggerHistory[i].pathStr) {
                            showingAlert = true
                        }
                        .alert(
                            "\(debugLoggerHistory[i].attributeStr)", isPresented: $showingAlert
                        ) {
                            Button("OK", role: .cancel) {}
                        }
                    } else {
                        Text(debugLoggerHistory[i].pathStr)
                    }
                }
            }
        }
    }
}
