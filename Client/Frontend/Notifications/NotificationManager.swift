// Copyright Neeva. All rights reserved.

import Combine
import Defaults
import Foundation
import Shared
import SwiftUI

private let logger = Logger.browser

class NotificationManager: ObservableObject {
    static let promoIdKey = "PromoId"
    static let shared = NotificationManager()

    @Published var notifications = [BaseNotification]() {
        didSet {
            saveNotitificationsToDevice(notifications)
        }
    }

    var upcomingNotifications: [BaseNotification] {
        notifications.filter { $0.dateReceived > Date() }
    }

    var readNotifications: [BaseNotification] {
        notifications.filter { !$0.isUnread }
    }

    var unreadNotifications: [BaseNotification] {
        notifications.filter { $0.isUnread && $0.dateReceived <= Date() }
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

    // MARK: - Notification Creation
    func createLocalNotification(
        identifier: String,
        promoId: String,
        type: NotificationType? = nil,
        timeInterval: TimeInterval,
        title: String,
        subtitle: String? = nil,
        body: String?,
        completionHandler: @escaping (Result<BaseNotification, Error>) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        if let body = body {
            content.body = body
        }
        content.userInfo[NotificationManager.promoIdKey] = promoId

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
            if let error = error {
                completionHandler(.failure(error))
            } else {
                let baseNotification = NeevaPromoNotification(
                    id: identifier, promoId: promoId,
                    type: type, title: title,
                    subtitle: subtitle, body: body,
                    dateReceived: Date(timeIntervalSinceNow: timeInterval))
                self.notifications.append(baseNotification)
                Defaults[.lastScheduledNeevaPromoID] = promoId
                completionHandler(.success(baseNotification))
            }
        }
    }

    func cancelLocalNotification(identifier: String) {
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])

        if let index = notifications.firstIndex(where: { $0.id == identifier }) {
            notifications.remove(at: index)
        }
    }

    func rescheduleNotification(identifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingNotifications in
            for notification in pendingNotifications where notification.identifier == identifier {
                self.cancelLocalNotification(identifier: identifier)

                if let trigger = notification.trigger as? UNTimeIntervalNotificationTrigger {
                    self.createLocalNotification(
                        identifier: notification.identifier,
                        promoId:
                            notification.content.userInfo[NotificationManager.promoIdKey] as? String
                            ?? "",
                        timeInterval: trigger.timeInterval,
                        title: notification.content.title, subtitle: notification.content.subtitle,
                        body: notification.content.body
                    ) { _ in }
                }
            }
        }
    }

    private var subscriptions: Set<AnyCancellable> = []

    func setupFeatureFlagUpdateHandler() {
        NeevaFeatureFlags.shared.$flagsUpdated.sink { flagsUpdated in
            if flagsUpdated {
                let notificationContent = NeevaFeatureFlags.latestValue(.localNotificationContent)
                let neevaPromo =
                    LocalNotitifications.parseNotificationPromoContent(content: notificationContent)
                if let neevaPromo = neevaPromo,
                    neevaPromo.promoId != Defaults[.lastScheduledNeevaPromoID]
                {
                    LocalNotitifications.scheduleNeevaPromoCallbackIfAuthorized(
                        callSite: LocalNotitifications.ScheduleCallSite.featureFlagUpdate
                    )
                }
            }
        }.store(in: &subscriptions)
    }

    // MARK: - Init
    init() {
        notifications = retrieveNotificationsFromDevice()
    }
}
