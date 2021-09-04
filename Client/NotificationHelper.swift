// Copyright Neeva. All rights reserved.

import Foundation
import UserNotifications

class NotificationHelper {
    static let shared = NotificationHelper()

    func isAuthorized(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, _ in
                print("Notification permission granted: \(granted)")

                guard granted else { return }
                self.getNotificationSettings()
            }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func unregisterNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}
