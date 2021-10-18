// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    // MARK: - Registering
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Defaults[.notificationToken] = token
        Defaults[.didRegisterNotificationTokenOnServer] = true
        NotificationPermissionHelper.shared.registerDeviceTokenWithServer(deviceToken: token)
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

        let request = response.notification.request

        switch NotificationType(rawValue: request.identifier) {
        case .neevaPromo:
            var tapAction: LocalNotitifications.LocalNotificationTapAction
            if !NeevaUserInfo.shared.isUserLoggedIn {
                bvc.presentIntroViewController(true)
                tapAction = LocalNotitifications.LocalNotificationTapAction.openIntroView
            } else {
                bvc.openURLInNewTab(NeevaConstants.appWelcomeToursURL)
                tapAction = LocalNotitifications.LocalNotificationTapAction.openWelcomeTour
            }
            var attributes = [
                ClientLogCounterAttribute(
                    key: LogConfig.NotificationAttribute.localNotificationTapAction,
                    value: tapAction.rawValue)
            ]
            if let promoId = request.content.userInfo[NotificationManager.promoIdKey] as? String {
                attributes.append(
                    ClientLogCounterAttribute(
                        key: LogConfig.NotificationAttribute.localNotificationPromoId,
                        value: promoId)
                )
            }
            ClientLogger.shared.logCounter(
                .OpenLocalNotification,
                attributes: attributes
            )
        case .none:
            break
        }

        completionHandler()
    }
}
