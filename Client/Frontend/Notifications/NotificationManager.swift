// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import SwiftUI

let logger = Logger.browser

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var notifications = [BaseNotification]() {
        didSet {
            saveNotitificationsToDevice(notifications)
        }
    }

    var readNotifications: [BaseNotification] {
        notifications.filter { !$0.isUnread }
    }

    var unreadNotifications: [BaseNotification] {
        notifications.filter { $0.isUnread }
    }

    var shouldShowBadge: Bool {
        unreadNotifications.count > 0
    }

    // MARK: - Updates
    func handleReceivedNotification(_ notification: BaseNotification) {
        notifications.insert(notification, at: 0)
    }

    // MARK: - Storage
    private var storageURL: URL? {
        guard
            let path = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: AppInfo.sharedContainerIdentifier)?.path
        else {
            return nil
        }

        return URL(fileURLWithPath: path).appendingPathComponent("notifications")
    }

    func saveNotitificationsToDevice(_ notifications: [BaseNotification]) {
        guard let path = storageURL?.absoluteString else {
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notifications)
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        } catch {
            logger.info("Failed to save notifications to device: \(error)")
        }
    }

    func retrieveNotificationsFromDevice() -> [BaseNotification] {
        guard let url = storageURL,
            FileManager.default.fileExists(atPath: url.absoluteString),
            let notificationData = try? Data(contentsOf: url)
        else {
            return [BaseNotification]()
        }

        do {
            if let notifications = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                notificationData)
                as? [BaseNotification]
            {
                return notifications
            }
        } catch {
            logger.info("Failed to retrieve notifications from device: \(error)")
        }

        return [BaseNotification]()
    }

    /// Deletes all read notifications that are 7+ days old.
    func purgeOldNotifications() {
        notifications = notifications.filter {
            $0.isUnread || $0.dateRead?.daysFromToday() ?? 0 <= 7
        }
    }

    func createLocalNotification(
        identifier: String,
        timeInterval: TimeInterval,
        title: String?,
        subtitle: String?,
        body: String?,
        completionHandler: @escaping (Error?) -> Void
    ) {
        let content = UNMutableNotificationContent()
        if let title = title {
            content.title = title
        }
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        if let body = body {
            content.body = body
        }

        // Create the trigger as a repeating event.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false)

        // Create the request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            completionHandler(error)
        }
    }

    func cancelLocalNotification(identifier: String) {
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Init
    init() {
        notifications = retrieveNotificationsFromDevice()
    }
}
