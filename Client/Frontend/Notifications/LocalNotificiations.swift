// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import Shared
import UserNotifications

class LocalNotitifications {
    static let notificationManager = NotificationManager.shared

    struct NeevaPromo {
        let promoId: String
        let title: String
        let body: String
    }

    public enum LocalNotificationTapAction: String {
        case openWelcomeTour = "openWelcomeTour"
        case openIntroView = "openIntroView"
    }

    public enum ScheduleCallSite: String {
        case enterForeground = "enterForeground"
        case authorizeNotification = "authorizedNotification"
        case featureFlagUpdate = "featureFlagUpdate"
    }

    // MARK: - Create Notifications
    static func scheduleNeevaPromoCallback(callSite: ScheduleCallSite) {
        rescheduleNotificationIfNeeded(
            for: .neevaPromo,
            completion: { exists, rescheduled in
                var scheduled = rescheduled
                if !exists {
                    scheduled = createNeevaPromoCallback()
                }
                if scheduled {
                    var attributes = [
                        ClientLogCounterAttribute(
                            key: LogConfig.NotificationAttribute.localNotificationScheduleCallSite,
                            value: callSite.rawValue)
                    ]
                    if let promoId = Defaults[.lastScheduledNeevaPromoID] {
                        attributes.append(
                            ClientLogCounterAttribute(
                                key: LogConfig.NotificationAttribute.localNotificationPromoId,
                                value: promoId)
                        )
                    }
                    ClientLogger.shared.logCounter(
                        .ScheduleLocalNotification,
                        attributes: attributes
                    )
                }
            })
    }

    static func scheduleNeevaPromoCallbackIfAuthorized(callSite: ScheduleCallSite) {
        NotificationPermissionHelper.shared.isAuthorized { authorized in
            if authorized {
                scheduleNeevaPromoCallback(callSite: callSite)
            }
        }
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
        for type: NotificationType, completion: @escaping (Bool, Bool) -> Void
    ) {
        isNotificationScheduled(type: type) { exists in
            var rescheduled = false
            if exists {
                notificationManager.cancelLocalNotification(identifier: type.rawValue)
                switch type {
                case .neevaPromo:
                    rescheduled = createNeevaPromoCallback()
                }
            }

            completion(exists, rescheduled)
        }
    }

    static func parseNotificationPromoContent(content: String) -> NeevaPromo? {
        let components = content.components(separatedBy: "##")
        if components.count != 3 {
            return nil
        }
        return NeevaPromo(
            promoId: components[0],
            title: components[1],
            body: components[2]
        )
    }

    // MARK: - Helpers
    private static func createNeevaPromoCallback() -> Bool {
        let type = NotificationType.neevaPromo
        let neevaPromo =
            parseNotificationPromoContent(
                content: NeevaFeatureFlags.latestValue(.localNotificationContent)
            )
        let notificationTriggerInterval = TimeInterval(
            NeevaFeatureFlags.latestValue(
                .localNotificationTriggerInterval
            )
        )

        if let neevaPromo = neevaPromo,
            shouldScheduleNeevaPromoNotification(
                triggerInterval: notificationTriggerInterval,
                promoId: neevaPromo.promoId
            )
        {
            notificationManager.createLocalNotification(
                identifier: type.rawValue,
                promoId: neevaPromo.promoId,
                type: type,
                timeInterval: notificationTriggerInterval,
                title: neevaPromo.title,
                body: neevaPromo.body
            ) { _ in }
            Defaults[.lastNeevaPromoScheduledTimeInterval] = Int(Date().timeIntervalSince1970)
            return true
        } else {
            return false
        }
    }

    private static func shouldScheduleNeevaPromoNotification(
        triggerInterval: TimeInterval,
        promoId: String
    ) -> Bool {
        if triggerInterval == 0 {
            return false
        }

        guard let lastScheduledTimeInterval = Defaults[.lastNeevaPromoScheduledTimeInterval],
            let lastPromoId = Defaults[.lastScheduledNeevaPromoID]
        else {
            return true
        }

        let timeIntervalElapsed =
            Date().timeIntervalSince1970 - TimeInterval(lastScheduledTimeInterval)

        return timeIntervalElapsed < TimeInterval(triggerInterval) || lastPromoId != promoId
    }
}
