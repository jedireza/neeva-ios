// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import UserNotifications
import XCGLogger

private let log = Logger.browser

extension AppDelegate: UNUserNotificationCenterDelegate {
    // MARK: - Registering
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Defaults[.notificationToken] = token
        #if DEBUG
            let environment = "sandbox"
        #else
            let environment = "production"
        #endif
        AddDeviceTokenIosMutation(
            input: DeviceTokenInput(
                deviceToken: token,
                deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                environment: environment)
        ).perform { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                log.error("Failed to add device token \(error)")
                break
            }
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register notifications: \(error)")
    }

    // MARK: - Handle Notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) ->
            Void
    ) {
        let content = notification.request.content
        NotificationManager.shared.handleReceivedNotification(
            BaseNotification(
                title: content.title, subtitle: content.subtitle, body: content.body,
                dateReceived: notification.date)
        )
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let bvc = SceneDelegate.getBVC(for: nil)

        switch NotificationType(rawValue: response.notification.request.identifier) {
        case .neevaPromo:
            if !NeevaUserInfo.shared.isUserLoggedIn {
                bvc.presentIntroViewController(true)
            } else {
                bvc.openURLInNewTab(NeevaConstants.appWelcomeToursURL)
            }
        case .none:
            break
        }

        completionHandler()
    }
}
