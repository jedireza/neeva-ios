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

class NeevaPromoNotification: BaseNotification {
    let promoId: String

    init(
        id: String = UUID().uuidString, promoId: String,
        type: NotificationType? = nil, title: String,
        subtitle: String? = nil, body: String? = nil,
        dateReceived: Date, dateRead: Date? = nil
    ) {
        self.promoId = promoId
        super.init(
            id: id,
            type: type,
            title: title,
            subtitle: subtitle,
            body: body,
            dateReceived: dateReceived,
            dateRead: dateRead
        )
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
