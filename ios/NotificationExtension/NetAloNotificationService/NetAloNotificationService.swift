//
//  NetAloNotificationService.swift
//  NetAloNotificationService
//
//  Created by Tran Phong on 8/16/21.
//

import UserNotifications
import Localize_Swift


public class NetAloNotificationService {
    private lazy var notificationRepo: NotificationRepo = NotificationRepoImpl()
    
    public enum Environment {
        case dev
        case prod
    }
    public init(environment: Environment, appGroupIdentifier: String) {
        switch environment {
        case .dev:
            NetAloBuildConfig.default = .dev
        default:
            NetAloBuildConfig.default = .prod
        }
        NetAloBuildConfig.default.appGroupIdentifier = appGroupIdentifier
    }
    
    public func didReceive(_ request: UNMutableNotificationContent, withContentHandler contentHandler: @escaping (UNNotificationContent?) -> Void) {
        
        // Update localize to use shared user default
        Localize.updateStandardStorage(identifier: NetAloBuildConfig.default.appGroupIdentifier)
        
        if let remoteNotification = self.getRemoteNotificationFrom(userInfo: request.userInfo) {
            switch remoteNotification {
            case .message(let remoteMessage):
                self.handle(remoteMessage: remoteMessage, bestAttemptContent: request, withContentHandler: contentHandler)
            case .startSecretChat(let startSecretChat):
                self.handle(startSecretChat: startSecretChat, bestAttemptContent: request, withContentHandler: contentHandler)
            case .deleteSecretChat(let deleteSecretChat):
                self.handle(deleteSecretChat: deleteSecretChat, bestAttemptContent: request, withContentHandler: contentHandler)
            }
        } else {
            contentHandler(nil)
        }
    }
    
    public func serviceExtensionTimeWillExpire(_ request: UNMutableNotificationContent, withContentHandler contentHandler: @escaping (UNNotificationRequest?) -> Void) {
        
    }
}

// MARK: - UTILS

private extension NetAloNotificationService {
    
    func getRemoteNotificationFrom(userInfo: [AnyHashable: Any]) -> RemoteNotification? {
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            return try JSONDecoder().decode(RemoteNotification.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
    
    func getRemoteMessageFromPayload(userInfo: [AnyHashable: Any]) -> RemoteMessage? {
        if let payload = userInfo["Payload"] as? String,
            let data = payload.data(using: .utf8),
            let remoteMessage = try? JSONDecoder().decode(RemoteMessage.self, from: data) {
            
            return remoteMessage
        }
        return nil
    }
    
    func replaceNotification(receivedNotification: UNMutableNotificationContent, remoteMessage: RemoteMessage) -> UNMutableNotificationContent {
        var _message = remoteMessage.message
        if _message.containsMentionText {
            let mentionedIds = _message.matches(for: "@[1-9][0-9]{10,15}").compactMap({ $0.replacingOccurrences(of: "@", with: "") })
            let metionedUsers = self.notificationRepo.getContactsInfo(ids: mentionedIds)
            for user in metionedUsers {
                _message = _message.replacingOccurrences(of: String(user.id), with: user.fullName)
            }
        }
        if remoteMessage.isFromPrivateGroup() {
            // Group type one-to-one
            receivedNotification.title = remoteMessage.senderName
            receivedNotification.body = _message
        } else {
            // Group type many
            receivedNotification.title = "Đến " + remoteMessage.groupName
            receivedNotification.subtitle = remoteMessage.senderName
            receivedNotification.body = _message
        }
        return receivedNotification
    }
    
    func replaceNotificationWithLocalName(receivedNotification: UNMutableNotificationContent, remoteMessage: RemoteMessage, qbMessage: QBMessage) -> UNMutableNotificationContent? {
        if
            let conversation = notificationRepo.getConversationInfo(id: qbMessage.dialogID),
            let contact = notificationRepo.getContactInfo(id: qbMessage.senderID) {
            
            if remoteMessage.isFromPrivateGroup() {
                return qbMessage.toRemoteNotification(type: .personal(contact.fullName), userNames: conversation.userNames)
            } else {
                return qbMessage.toRemoteNotification(type: .group(conversation.displayNameForSender(qbMessage.senderID), contact.fullName), userNames: conversation.userNames)
            }
        } else {
            if remoteMessage.isFromPrivateGroup() {
                return qbMessage.toRemoteNotification(type: .personal(remoteMessage.senderName), userNames: [remoteMessage.senderUin: remoteMessage.senderName])
            } else {
                return qbMessage.toRemoteNotification(type: .group(remoteMessage.groupName, remoteMessage.senderName), userNames: [remoteMessage.senderUin: remoteMessage.senderName])
            }
        }
    }
    
    func handle(remoteMessage: RemoteMessage,  bestAttemptContent: UNMutableNotificationContent, withContentHandler contentHandler: @escaping (UNNotificationContent?) -> Void) {
        if
            let qbMessage = try? QBMessage(message: remoteMessage),
            let localizedContent = self.replaceNotificationWithLocalName(receivedNotification: bestAttemptContent, remoteMessage: remoteMessage, qbMessage: qbMessage) {
            
            // Save local conversation
            if case .groupUpdate(let groupUpdateType) = qbMessage.kind {
                self.handleLocalConversation(id: qbMessage.dialogID, and: groupUpdateType)
            }
            
            // Save local message
            if qbMessage.isEncrypted == false {
                self.notificationRepo.saveMessage(qbMessage)
            }
            
            // Update bage
            localizedContent.badge = NSNumber(value: self.notificationRepo.getUnreadConversationsAndMissedCalls())
            
            contentHandler(localizedContent)
        } else {
            let localizedContent = self.replaceNotification(receivedNotification: bestAttemptContent, remoteMessage: remoteMessage)
            
            // Update bage
            localizedContent.badge = NSNumber(value: self.notificationRepo.getUnreadConversationsAndMissedCalls())
            
            contentHandler(localizedContent)
        }
    }
    
    func handle(startSecretChat: RemoteStartSecretChat,  bestAttemptContent: UNMutableNotificationContent, withContentHandler contentHandler: @escaping (UNNotificationContent?) -> Void) {
        
        // Replace the notification content
        if let contact = notificationRepo.getContactInfo(id: startSecretChat.uin) {
            bestAttemptContent.title = contact.fullName
        }
        bestAttemptContent.body = "request_new_secret_chat".localized
        contentHandler(bestAttemptContent)
    }
    
    func handle(deleteSecretChat: RemoteDeleteSecretChat,  bestAttemptContent: UNMutableNotificationContent, withContentHandler contentHandler: @escaping (UNNotificationContent?) -> Void) {
        
        // Replace the notification content
        if
            let currentUserId = notificationRepo.getCurrentUserId(),
            let conv = notificationRepo.getConversationInfo(id: deleteSecretChat.groupID),
            let oponentUser = conv.occupantUsers.first(where: { $0.id != currentUserId }) {
            bestAttemptContent.title = oponentUser.fullName
        }
        bestAttemptContent.body = "delete_secret_chat".localized
        
        // Remove conversation from local
        self.notificationRepo.removeConversation(id: deleteSecretChat.groupID)
        
        contentHandler(bestAttemptContent)
    }
    
    func handleLocalConversation(id: String, and type: QBGroupUpdateType) {
        switch type {
        case .updateInfo(let name, let avatarUrl):
            if name.count > 0 {
                self.notificationRepo.updateConversationName(id: id, conversationName: name)
            }
            if avatarUrl.count > 0 {
                self.notificationRepo.updateConversationAvatarUrl(id: id, avatarUrl: avatarUrl)
            }
        case .addMembers(let ids):
            self.notificationRepo.addMembersToConversation(id: id, memberIds: ids)
        case .removeMember(let id):
            self.notificationRepo.removeMemberInConversation(id: id, memberId: id)
        case .changeOwner(let id):
            self.notificationRepo.changeOwnerOfConversation(id: id, ownerId: id)
        case .updateMessageDeleteTimer(let timeToLive):
            self.notificationRepo.saveReceiverMessageTimeToLive(groupId: id, messageTimeToLive: timeToLive)
        case .updatedGroupBackground(let background):
            self.notificationRepo.updateConversationBackground(id: id, background: background)
            break
        }
    }
}
