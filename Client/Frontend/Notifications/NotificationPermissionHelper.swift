// Copyright Neeva. All rights reserved.

import Foundation
import UserNotifications

class NotificationPermissionHelper {
    static let shared = NotificationPermissionHelper()

    func didAlreadyRequestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus != .notDetermined)
        }
    }

    func isAuthorized(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(
                settings.authorizationStatus != .denied
                    && settings.authorizationStatus != .notDetermined)
        }
    }

    func requestPermissionIfNeeded(openSettingsIfNeeded: Bool = false) {
        isAuthorized { [self] authorized in
            guard !authorized else { return }

            didAlreadyRequestPermission { requested in
                if !requested {
                    requestPermissionFromSystem()
                } else if openSettingsIfNeeded {
                    /// If we can't show the iOS system notification because the user denied our first request,
                    /// this will take them to system settings to enable notifications there.
                    SystemsHelper.openSystemSettingsNeevaPage()
                }
            }
        }
    }

    /// Shows the iOS system popup to request notification permission.
    /// Will only show **once**, and if the user has not denied permission already.
    func requestPermissionFromSystem() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [
                .alert, .sound, .badge, .providesAppNotificationSettings,
            ]) { granted, _ in
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

    func unregisterRemoteNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}
