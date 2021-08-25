//
//  NotificationService.swift
//  NotificationExtention
//
//  Created by Tran Phong on 7/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import UserNotifications
import Localize_Swift

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    private lazy var notificationService = NetAloNotificationService(environment: .dev, appGroupIdentifier: BuildConfig.default.appGroupIdentifier)

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        self.bestAttemptContent?.sound = UNNotificationSound(named: .init(rawValue: "notification_sound.wav"))
        
        // Update localize to use shared user default
        Localize.updateStandardStorage(identifier: BuildConfig.default.appGroupIdentifier)
        
        if let bestAttemptContent = self.bestAttemptContent {
            notificationService.didReceive(bestAttemptContent) { (replaceContent) in
                if let replaceContent = replaceContent {
                    contentHandler(replaceContent)
                } else {
                    contentHandler(bestAttemptContent)
                }
            }
        } else {
            contentHandler(request.content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if
//            let contentHandler = contentHandler,
//            let bestAttemptContent =  bestAttemptContent {
//            
//            if let remoteMessage = self.getRemoteMessageFromPayload(userInfo: bestAttemptContent.userInfo) {
//                contentHandler(replaceNotification(receivedNotification: bestAttemptContent, remoteMessage: remoteMessage))
//            } else {
//                contentHandler(bestAttemptContent)
//            }
//        }
    }
}
