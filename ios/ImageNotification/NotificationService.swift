import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Look for image URL in the FCM payload
        // FCM sends it as "fcm_options" > "image" or in the "image" key directly
        var imageURLString: String?

        if let fcmOptions = bestAttemptContent.userInfo["fcm_options"] as? [String: Any],
           let image = fcmOptions["image"] as? String {
            imageURLString = image
        } else if let image = bestAttemptContent.userInfo["image"] as? String {
            imageURLString = image
        }

        guard let urlString = imageURLString,
              let url = URL(string: urlString) else {
            contentHandler(bestAttemptContent)
            return
        }

        // Download the image and attach it
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            defer { contentHandler(bestAttemptContent) }

            guard let location = location, error == nil else { return }

            let tmpDir = FileManager.default.temporaryDirectory
            let filename = url.lastPathComponent.isEmpty ? "notification_image.jpg" : url.lastPathComponent
            let tmpFile = tmpDir.appendingPathComponent(filename)

            try? FileManager.default.removeItem(at: tmpFile)
            try? FileManager.default.moveItem(at: location, to: tmpFile)

            if let attachment = try? UNNotificationAttachment(identifier: "image", url: tmpFile, options: nil) {
                bestAttemptContent.attachments = [attachment]
            }
        }
        task.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
