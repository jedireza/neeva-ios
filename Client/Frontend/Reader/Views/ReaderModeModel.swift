// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import Shared

class ReaderModeModel: ObservableObject {
    @Published var state: ReaderModeState = .unavailable
    @Published var style: ReaderModeStyle = ReaderModeStyle(
        theme: .light, fontType: .sansSerif)

    let setReadingMode: (Bool) -> Void
    let tabManager: TabManager

    var delegate: ReaderModeDelegate?
    var brightnessModel = ReaderModeBrightnessModel()
    var isOriginalTabSecure: Bool = false

    fileprivate var isUsingUserDefinedColor = false

    func enableReadingMode() {
        isOriginalTabSecure = tabManager.selectedTab?.webView?.hasOnlySecureContent ?? false
        setReadingMode(true)
    }

    func disableReadingMode() {
        isOriginalTabSecure = false
        setReadingMode(false)
    }

    func changeTheme(to: ReaderModeTheme) {
        style.theme = to

        isUsingUserDefinedColor = true
        delegate?.readerMode(
            didConfigureStyle: style, isUsingUserDefinedColor: isUsingUserDefinedColor)
    }

    func applyTheme(contentScript: TabContentScript) {
        guard let readerMode = contentScript as? ReaderMode else { return }

        var style = Defaults[.readerModeStyle] ?? readerMode.defaultTheme
        style.ensurePreferredColorThemeIfNeeded()
        readerMode.style = style
    }

    init(setReadingMode: @escaping (Bool) -> Void, tabManager: TabManager) {
        self.setReadingMode = setReadingMode
        self.tabManager = tabManager
    }
}
