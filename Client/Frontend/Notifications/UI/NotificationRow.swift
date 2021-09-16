// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct NotificationRow: View {
    let notification: BaseNotification
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if notification.isUnread {
                    NotificationBadge(count: nil)
                        .padding(.trailing)
                }

                GenericNotificationRow(notification: notification)

                VStack {
                    Text("\(notification.dateReceived.timeFromNowString())")
                        .withFont(.bodyMedium)
                    Spacer()
                }
            }
            .padding()
        }
        .fixedSize(horizontal: false, vertical: true)
        .buttonStyle(TableCellButtonStyle())
        .background(Color.background)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct GenericNotificationRow: View {
    let notification: BaseNotification

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(notification.title)
                    .withFont(.headingMedium)
                Text(notification.body ?? "")
                    .withFont(.bodyMedium)
            }.foregroundColor(.label)

            Spacer()
        }
    }
}

struct NotificationRow_Previews: PreviewProvider {
    static let mockNotification = BaseNotification(title: "Test", body: "This is a test!", dateReceived: Date())

    static var previews: some View {
        NotificationRow(notification: mockNotification, action: {})
    }
}
