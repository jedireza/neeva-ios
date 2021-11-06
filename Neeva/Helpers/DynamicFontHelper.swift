/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

private let iPadFactor: CGFloat = 1.06
private let iPhoneFactor: CGFloat = 0.88

class DynamicFontHelper: NSObject {

    static var defaultHelper: DynamicFontHelper {
        struct Singleton {
            static let instance = DynamicFontHelper()
        }
        return Singleton.instance
    }

    override init() {
        // 14pt -> 17pt -> 23pt
        defaultStandardFontSize =
            UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).pointSize
        deviceFontSize =
            defaultStandardFontSize
            * (UIDevice.current.userInterfaceIdiom == .pad ? iPadFactor : iPhoneFactor)
        // 11pt -> 12pt -> 17pt
        defaultSmallFontSize =
            UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption1).pointSize

        super.init()
    }

    /// Starts monitoring the `ContentSizeCategory` changes
    func startObserving() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Device specific
    fileprivate var deviceFontSize: CGFloat
    var DeviceFontLight: UIFont {
        return UIFont.systemFont(ofSize: deviceFontSize, weight: UIFont.Weight.light)
    }
    var DeviceFontHistoryPanel: UIFont {
        return UIFont.systemFont(ofSize: deviceFontSize)
    }

    /*
     Activity Stream supports dynamic fonts up to a certain point. Large fonts dont work.
     Max out the supported font size.
     Small = 14, medium = 18, larger = 20
     */

    var SmallSizeRegularWeightAS: UIFont {
        let size = min(defaultSmallFontSize, 14)
        return UIFont.systemFont(ofSize: size)
    }

    /// Small
    fileprivate var defaultSmallFontSize: CGFloat
    var DefaultSmallFont: UIFont {
        return UIFont.systemFont(ofSize: defaultSmallFontSize, weight: UIFont.Weight.regular)
    }

    /// Reader mode
    fileprivate var defaultStandardFontSize: CGFloat
    var ReaderStandardFontSize: CGFloat {
        return defaultStandardFontSize - 2
    }
    var ReaderBigFontSize: CGFloat {
        return defaultStandardFontSize + 5
    }

    func refreshFonts() {
        defaultStandardFontSize =
            UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).pointSize
        deviceFontSize =
            defaultStandardFontSize
            * (UIDevice.current.userInterfaceIdiom == .pad ? iPadFactor : iPhoneFactor)
        defaultSmallFontSize =
            UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption2).pointSize
    }

    @objc func contentSizeCategoryDidChange(_ notification: Notification) {
        refreshFonts()
        let notification = Notification(name: .DynamicFontChanged, object: nil)
        NotificationCenter.default.post(notification)
    }
}
