// Copyright Neeva. All rights reserved.

import SwiftUI

struct NotificationList: View {
    var notifications: [BaseNotification]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(notifications, id: \.id) { notification in
                    NotificationRow(notification: notification, action: {})
                }
            }
        }
        .background(
            Color(UIColor.systemGroupedBackground)
            .edgesIgnoringSafeArea(.all)
        )
    }
}

struct NotificationList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationList(notifications: [
            BaseNotification(title: "Testing Notification One", body: "This is the first test notification.", dateReceived: Date()),
            BaseNotification(title: "Testing Notification Two", body: "This is the second test notification.", dateReceived: Date()),
            BaseNotification(title: "Testing Notification Third", body: "This is the third test notification.", dateReceived: Date()),
        ])
    }
}
