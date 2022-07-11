//
//  QBMessage+Notification.swift
//  Netalo
//
//  Created by Tran Phong on 7/6/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import UIKit

public enum QBMessageNotificationType {
    case personal(String)
    case group(String, String)
}

extension QBMessage {
    func toRemoteNotification(type: QBMessageNotificationType, userNames: [String: String]) -> UNMutableNotificationContent? {
        let content = UNMutableNotificationContent()
        var title: String = ""
        var subtitle: String = ""
        var body: String = ""
        let senderName = userNames.getName(userId: senderID)
        
        switch self.kind {
        case .text(let text):
            body = text
            break
        case .images:
            body = "Photos".localized
            break
        case .video:
            body = "Videos".localized
            break
        case .file:
            body = "Send file".localized
        case .call(let call):
            if call.type == "voice_missed" {
                body = "You_missed_a_voice_call".localized
            }
            else if call.type == "video_missed" {
                body = "You_missed_a_video_call".localized
            } else {
                // Un handle call type
                return nil
            }
            break
        case .audio:
            body = "Recording".localized
            break
        case .reply(let text, _):
            body = text
            break
        case .leaveGroup:
            body = "%@ left group".localizedFormat(senderName)
        case .firstMessage:
            switch type {
            case .personal(_ ):
                body = "%@ has started the conversation".localizedFormat(senderName)
            default:
                body = "%@ just created the group".localizedFormat(senderName)
            }
            
        case .groupUpdate(let updateType):
            switch updateType {
            case .addMembers(let members):
                let memberNames = members.compactMap { userNames.getName(userId: $0, upperCase: false) }
                body = "%@ added %@".localizedFormat(senderName, memberNames.joined(separator: ", "))
            case .removeMember(let member):
                let memberName = userNames.getName(userId: member, upperCase: false)
                body = "%@ removed %@".localizedFormat(senderName, memberName)
                
            case .updateInfo(let name, let avatar):
                if name.count > 0 && avatar.count > 0 {
                    body = "%@ updated group info".localizedFormat(senderName)
                } else if avatar.count > 0 {
                    body = "%@ updated group avatar".localizedFormat(senderName)
                } else if name.count > 0 {
                    body = "%@ renamed group to %@".localizedFormat(senderName, name)
                }
                
            case .changeOwner(let uin):
                let memberName = userNames.getName(userId: uin, upperCase: false)
                body = "\(senderName) \("selected".localized) \(memberName) \("as_new_admin".localized)"
                
            case .updateMessageDeleteTimer(let timer):
                body = "%@ set message delete timer to".localizedFormat(senderName) + " " + "%d seconds".localizedPlural(Int(timer))
                
            case .updatedGroupBackground:
                body = "\(senderName) vừa thay đổi hình nền của cuộc hội thoại"
            }
        case .sticker:
            body = "Sticker"
        case .screenshot:
            body = "%@ took a screenshot".localizedFormat(senderName)
        default:
            return nil
        }
        
        if case .personal(let name) = type {
            title = name
        }
        else if case .group(let groupName, let contactName) = type {
            title = "to".localized + groupName
            subtitle = contactName
        }
        
        if body.containsMentionText {
            let mentionedIds = body.matches(for: "@[1-9][0-9]{10,15}").compactMap({ $0.replacingOccurrences(of: "@", with: "") })
            for userId in mentionedIds {
                body = body.replacingOccurrences(of: userId, with: userNames[userId] ?? "\(userId)")
            }
        }
        
        // For encrypted message
        if self.isEncrypted {
            body = "The_message_is_encrypted".localized
        }
        
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.threadIdentifier = self.dialogID
        content.sound = .init(named: .init("notification_sound.wav"))
        
        // TODO: Set cleaner userInfo key
        if let encodedData = try? JSONEncoder().encode(self) {
            content.userInfo = ["qbmessage": encodedData]
        }
        
        return content
    }
}

fileprivate extension Dictionary where Key == String, Value == String {
    func getName(userId: String, upperCase: Bool = true) -> String {
        if let name = self[userId], name.count > 0, name != userId {
            return name
        }
        return (upperCase ? "Someone".localized : "someone".localized)
    }
}
