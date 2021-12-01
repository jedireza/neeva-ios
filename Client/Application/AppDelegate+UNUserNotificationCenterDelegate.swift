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
        let receivedNotification = BaseNotification(
            title: content.title, subtitle: content.subtitle, body: content.body,
            dateReceived: notification.date)
        NotificationManager.shared.handleReceivedNotification(receivedNotification)

        let state = application?.applicationState
        if state == .active {
            NotificationManager.shared.showInAppNotification(notification: receivedNotification)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let bvc = SceneDelegate.getBVC(for: nil)
        let request = response.notification.request

        NotificationManager.shared.handleNotification(request: request, bvc: bvc)

        completionHandler()
    }
}
