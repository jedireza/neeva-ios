// Copyright Neeva. All rights reserved.

import Foundation

struct BaseNotification: Codable, Identifiable {
    var id = UUID()

    let title: String
    var subtitle: String? = nil
    let body: String?

    var dateReceived: Date
    var dateRead: Date? = nil

    var isUnread: Bool {
        dateRead == nil
    }

    mutating func notificationRead() {
        dateRead = Date()
    }
}
