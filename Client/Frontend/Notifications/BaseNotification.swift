// Copyright Neeva. All rights reserved.

import Foundation

enum NotificationType: String, Codable {
    case neevaPromo = "neevaPromo"
}

class BaseNotification: Codable, Identifiable {
    let id: String
    let type: NotificationType?

    let title: String
    let subtitle: String?
    let body: String?

    let dateReceived: Date
    var dateRead: Date? = nil

    var isUnread: Bool {
        dateRead == nil
    }

    func notificationRead() {
        dateRead = Date()
    }

    init(
        id: String = UUID().uuidString, type: NotificationType? = nil, title: String,
        subtitle: String? = nil, body: String? = nil,
        dateReceived: Date, dateRead: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.dateReceived = dateReceived
        self.dateRead = dateRead
    }
}
