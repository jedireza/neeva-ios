// Copyright Neeva. All rights reserved.

import Foundation
import UserNotifications

class LocalNotitifications {
    static let notificationManager = NotificationManager.shared

    // MARK: - Create Notifications
    static func createNeevaPromoCallback() {
        let type = NotificationType.neevaPromo
        notificationManager.createLocalNotification(
            identifier: type.rawValue, type: type, timeInterval: TimeInterval.days(7),
            title: "You are not the product",
            body: "Neeva is search that's built for you, not advertisers. See the difference."
        ) { _ in }
    }

    // MARK: - Rescheduling
    static func isNotificationScheduled(
        type: NotificationType, completion: @escaping (Bool) -> Void
    ) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingNotifications in
            var exists = false

            for notification in pendingNotifications where notification.identifier == type.rawValue
            {
                exists = true
            }

            completion(exists)
        }
    }

    static func rescheduleNotificationIfNeeded(
        for type: NotificationType, completion: @escaping (Bool) -> Void
    ) {
        isNotificationScheduled(type: type) { exists in
            if exists {
                notificationManager.rescheduleNotification(identifier: type.rawValue)
            }

            completion(exists)
        }
    }
}
