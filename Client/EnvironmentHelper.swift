// Copyright Neeva. All rights reserved.

import Foundation
import Shared

public class EnvironmentHelper {
    public static let shared = EnvironmentHelper()

    public var env: ClientLogEnvironment {
        #if DEBUG
            return ClientLogEnvironment(rawValue: "Dev")!
        #else
            return ClientLogEnvironment(rawValue: "Prod")!
        #endif
    }

    public var themeStyle: String {
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        default:
            return "Unknown"
        }
    }

    public var orientation: String {
        switch UIDevice.current.orientation {
        case .unknown:
            return "Unknown"
        case .portrait:
            return "Portrait"
        case .portraitUpsideDown:
            return "PortraitUpsideDown"
        case .landscapeLeft:
            return "LandscapeLeft"
        case .landscapeRight:
            return "LandscapeRight"
        case .faceUp:
            return "FaceUp"
        case .faceDown:
            return "FaceDown"
        default:
            return "Unknown"
        }
    }

    public var screenSize: String {
        return "\(UIScreen.main.bounds.width) x \(UIScreen.main.bounds.height)"
    }

    public func getAttributes() -> [ClientLogCounterAttribute] {
        // selected tab is private
        let tabManager = SceneDelegate.getTabManager()
        let isPrivate =
            tabManager.selectedTab?.isPrivate ?? false
        let isPrivateMode = ClientLogCounterAttribute(
            key: LogConfig.Attribute.IsInPrivateMode, value: String(isPrivate))

        // number of normal tabs opened
        let normalTabsOpened = ClientLogCounterAttribute(
            key: LogConfig.Attribute.NormalTabsOpened,
            value: String(tabManager.normalTabs.count))

        // number of private tabs opened
        let privateTabsOpened = ClientLogCounterAttribute(
            key: LogConfig.Attribute.PrivateTabsOpened,
            value: String(tabManager.privateTabs.count))

        // user theme setting
        let deviceTheme = ClientLogCounterAttribute(
            key: LogConfig.Attribute.UserInterfaceStyle, value: self.themeStyle)

        // orientation
        let deviceOrientation = ClientLogCounterAttribute(
            key: LogConfig.Attribute.DeviceOrientation, value: self.orientation)

        // screensize
        let deviceScreensSize = ClientLogCounterAttribute(
            key: LogConfig.Attribute.DeviceScreenSize, value: self.screenSize)

        // is user signed in
        let isUserSignedIn = ClientLogCounterAttribute(
            key: LogConfig.Attribute.isUserSignedIn,
            value: String(NeevaUserInfo.shared.hasLoginCookie()))

        let attributes = [
            isPrivateMode, normalTabsOpened, privateTabsOpened, deviceTheme, deviceOrientation,
            deviceScreensSize, isUserSignedIn,
        ]

        return attributes
    }
}
