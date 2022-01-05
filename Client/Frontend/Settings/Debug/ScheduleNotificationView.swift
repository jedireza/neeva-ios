// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI
import Defaults

struct ScheduleNotificationView: View {
    @Environment(\.dismissScreen) var dismissScreen

    @Default(.debugNotificationTitle) var debugNotificationTitle
    @Default(.debugNotificationBody) var debugNotificationBody
    @Default(.debugNotificationDeeplink) var debugNotificationDeeplink
    @Default(.debugNotificationTimeInterval) var debugNotificationTimeInterval

    var body: some View {
        List {
            OptionalStringField("Title", text: $debugNotificationTitle)
            OptionalStringField("Body", text: $debugNotificationBody)
            OptionalStringField("Deeplink", text: $debugNotificationDeeplink)
            NumberField("TimeInterval", number: $debugNotificationTimeInterval)
            Button {
                NotificationManager.shared.createLocalNotification(
                    identifier: "debug_notification",
                    promoId: "debug_campaign",
                    type: nil,
                    timeInterval: TimeInterval(debugNotificationTimeInterval),
                    title: debugNotificationTitle ?? "",
                    body: debugNotificationBody,
                    deeplinkUrl: debugNotificationDeeplink
                ) { _ in
                    DispatchQueue.main.async {
                        dismissScreen()
                    }
                }
            } label: {
                Text("Schedule")
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ScheduleNotification_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleNotificationView()
                .navigationTitle("Schedule Notification")
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
