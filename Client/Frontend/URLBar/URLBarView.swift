// Copyright Neeva. All rights reserved.

import SwiftUI

struct URLBarView: View {
    let onReload: () -> ()
    let onSubmit: (String) -> ()
    let onShare: (UIView) -> ()
    let buildReloadMenu: () -> UIMenu?
    let showsToolbar: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TabLocationView(onReload: onReload, onSubmit: onSubmit, onShare: onShare, buildReloadMenu: buildReloadMenu)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 10)
                    .padding(.top, -2)
            }
            .background(Color.chrome.ignoresSafeArea())
            Color.ui.adaptive.separator.frame(height: 0.5)
        }
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            URLBarView(onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }, showsToolbar: false)
                .environmentObject(URLBarModel(previewURL: nil, isSecure: true))
            Spacer()
        }

        VStack {
            URLBarView(onReload: {}, onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil }, showsToolbar: false)
                .environmentObject(URLBarModel(previewURL: nil, isSecure: true))
            Spacer()
        }
        .preferredColorScheme(.dark)
    }
}
