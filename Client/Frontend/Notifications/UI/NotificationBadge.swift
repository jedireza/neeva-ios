// Copyright Neeva. All rights reserved.

import SwiftUI

/// Used for adding a badge **into** a view.
struct NotificationBadge: View {
    let count: Int?
    private let maxCount = 99
    private let smallCircleSize: CGFloat = 8

    var textOversized: Bool {
        count ?? 0 > maxCount
    }

    var size: CGFloat {
        count == nil ? smallCircleSize : 20
    }

    var body: some View {
        ZStack {
            if !textOversized {
                Circle()
            } else {
                RoundedRectangle(cornerRadius: size)
            }

            if let count = count {
                Text(textOversized ? "\(maxCount)+" : String(count))
                    .font(.system(size: 10))
                    .padding(.vertical, 3)
                    .padding(.horizontal, textOversized ? 10 : 5)
                    .foregroundColor(.white)
            }
        }
        .foregroundColor(.blue)
        .frame(minHeight: smallCircleSize)
        .fixedSize()
    }
}

enum NotificationBadgeLocation {
    case left
    case right
    case top
    case bottom

    static let topLeft = [NotificationBadgeLocation.left, NotificationBadgeLocation.top]
    static let topRight = [NotificationBadgeLocation.right, NotificationBadgeLocation.top]
    static let bottomLeft = [NotificationBadgeLocation.left, NotificationBadgeLocation.bottom]
    static let bottomRight = [NotificationBadgeLocation.right, NotificationBadgeLocation.bottom]
}

/// Used for **overlaying** a badge overlay over an entire view.
struct NotificationBadgeOverlay<Content: View>: View {
    let from: [NotificationBadgeLocation]
    var count: Int?
    let content: Content

    var horizontalPadding: CGFloat {
        let count = count ?? 0
        if count > 99 {
            return -20
        } else if count > 9 {
            return 0
        } else {
            return 3
        }
    }

    @ViewBuilder
    var horizontalAlignedContent: some View {
        HStack {
            if from.contains(.left) {
                NotificationBadge(count: count)
                    .padding(.top, 3)
                    .padding(.leading, horizontalPadding)
                Spacer()
            } else if from.contains(.right) {
                Spacer()
                NotificationBadge(count: count)
                    .padding(.top, 3)
                    .padding(.trailing, horizontalPadding)
            } else {
                Spacer()
                NotificationBadge(count: count)
                Spacer()
            }
        }
    }

    var body: some View {
        ZStack {
            content

            VStack {
                if from.contains(.top) {
                    horizontalAlignedContent
                    Spacer()
                } else if from.contains(.bottom) {
                    Spacer()
                    horizontalAlignedContent
                } else {
                    Spacer()
                    horizontalAlignedContent
                    Spacer()
                }
            }
        }.fixedSize()
    }
}

struct NotificationBadge_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NotificationBadge(count: nil)
            NotificationBadge(count: 1)
            NotificationBadge(count: 22)
            NotificationBadge(count: 100)
        }
    }
}
