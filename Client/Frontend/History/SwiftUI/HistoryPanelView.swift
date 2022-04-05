// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct HistoryPanelView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    
                }
                
                
            }
            .navigationTitle("History")
            .toolbar {
                Button {
                    
                } label: {
                    Text("Done")
                }
            }
        }.navigationBarTitleDisplayMode(.inline)
    }
}

struct HistoryPanelView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryPanelView()
    }
}
