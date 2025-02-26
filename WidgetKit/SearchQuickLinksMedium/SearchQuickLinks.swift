/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entries = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    public typealias Entry = SimpleEntry
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
}

struct SearchQuickLinksEntryView: View {
    @ViewBuilder
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 8.0) {
                ImageButtonWithLabel(isSmall: false, link: .search)
                ImageButtonWithLabel(isSmall: false, link: .incognitoSearch)
            }
            HStack(alignment: .top, spacing: 8.0) {
                ImageButtonWithLabel(isSmall: false, link: .copiedLink)
                ImageButtonWithLabel(isSmall: false, link: .closeIncognitoTabs)
            }
        }
        .padding(10.0)
        .background(Color("backgroundColor"))
    }
}

struct SearchQuickLinksWidget: Widget {
    private let kind: String = "Quick Actions - Medium"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SearchQuickLinksEntryView()
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName(String.QuickActionsGalleryTitlev2)
        .description(String.NeevaShortcutGalleryDescription)
    }
}

struct SearchQuickLinksPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchQuickLinksEntryView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            SearchQuickLinksEntryView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)

            SearchQuickLinksEntryView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.sizeCategory, .small)

            SearchQuickLinksEntryView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.sizeCategory, .accessibilityLarge)
        }
    }
}
