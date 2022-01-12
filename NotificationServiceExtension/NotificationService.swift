// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        defer {
            contentHandler(bestAttemptContent ?? request.content)
        }

        guard let attachment = request.attachment else {
            return
        }

        bestAttemptContent?.attachments = [attachment]
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension UNNotificationRequest {
    var attachment: UNNotificationAttachment? {
        guard let attachmentURL = content.userInfo["mediaURL"] as? String, let imageData = try? Data(contentsOf: URL(string: attachmentURL)!) else {
            return nil
        }

        return try? UNNotificationAttachment(data: imageData, options: nil)
    }
}

extension UNNotificationAttachment {

    convenience init(data: Data, options: [NSObject: AnyObject]?) throws {
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)

        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
        let imageFileIdentifier = UUID().uuidString + ".jpg"
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        try data.write(to: fileURL)
        try self.init(identifier: imageFileIdentifier, url: fileURL, options: options)
    }
}
