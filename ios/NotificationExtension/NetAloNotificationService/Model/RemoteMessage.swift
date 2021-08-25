//
//  RemoteMessage.swift
//  NotificationExtention
//
//  Created by Tran Phong on 7/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

enum RemoteNotification: Codable {
    case message(RemoteMessage)
    case startSecretChat(RemoteStartSecretChat)
    case deleteSecretChat(RemoteDeleteSecretChat)
    
    enum Key: String, CodingKey {
        case type = "Type"
        case payload = "Payload"
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let typeValue = container.decodex(key: .type, defaultValue: "message")
        let payloadStr = container.decodex(key: .payload, defaultValue: "")
        let data = payloadStr.data(using: .utf8) ?? Data()
        
        switch typeValue {
        case "message", "secret_message":
            do {
                let msg = try JSONDecoder().decode(RemoteMessage.self, from: data)
                self = .message(msg)
            } catch {
                print(error)
                throw CodingError.unknownValue
            }
        case "start_secret_chat":
            self = .startSecretChat(try JSONDecoder().decode(RemoteStartSecretChat.self, from: data))
        case "delete_secret_chat":
            self = .deleteSecretChat(try JSONDecoder().decode(RemoteDeleteSecretChat.self, from: data))
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(type(), forKey: .type)
        
        switch self {
        case .message(let remoteMessage):
            try container.encode(remoteMessage, forKey: .payload)
        case .startSecretChat(let startSecretChat):
            try container.encode(startSecretChat, forKey: .payload)
        case .deleteSecretChat(let deleteSecretChat):
            try container.encode(deleteSecretChat, forKey: .payload)
        }
    }
    
    func type() -> String {
        switch self {
        case .message:
            return "message"
        case .startSecretChat:
            return "start_secret_chat"
        case .deleteSecretChat:
            return "delete_secret_chat"
        }
    }
}

struct RemoteMessage: Codable {
    var messageId: String
    var groupId: String
    var message: String
    var senderUin: String
    var createdAt: String
    var recipientUins: [String]
    var seenUins: [String]
    var senderName: String
    var groupName: String
    var groupType: String
    var type: String
    var version: Int
    var attachments: String
    var isEncrypted: Bool
    
    enum CodingKeys: String, CodingKey {
        case messageId
        case groupId
        case message
        case senderUin
        case createdAt
        case recipientUins
        case seenUins
        case senderName
        case groupName
        case groupType
        case type
        case version
        case attachments, isEncrypted
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        messageId = values.decodex(key: .messageId, defaultValue: "")
        groupId = values.decodex(key: .groupId, defaultValue: "")
        message = values.decodex(key: .message, defaultValue: "")
        senderUin = values.decodex(key: .senderUin, defaultValue: "")
        createdAt = values.decodex(key: .createdAt, defaultValue: "")
        recipientUins = values.decodex(key: .recipientUins, defaultValue: [])
        seenUins = values.decodex(key: .seenUins, defaultValue: [])
        senderName = values.decodex(key: .senderName, defaultValue: "")
        groupName = values.decodex(key: .groupName, defaultValue: "")
        groupType = values.decodex(key: .groupType, defaultValue: "")
        type = values.decodex(key: .type, defaultValue: "")
        attachments = values.decodex(key: .attachments, defaultValue: "")
        version = values.decodex(key: .version, defaultValue: 0)
        isEncrypted = values.decodex(key: .isEncrypted, defaultValue: false)
    }
    
    func getType() -> Int {
        switch type {
        case "MESSAGE_TYPE_TEXT":
            return NTMessageType.text.rawValue
        case "MESSAGE_TYPE_CALL":
            return NTMessageType.call.rawValue
        case "MESSAGE_TYPE_IMAGE":
            return NTMessageType.images.rawValue
        case "MESSAGE_TYPE_AUDIO":
            return NTMessageType.audio.rawValue
        case "MESSAGE_TYPE_VIDEO":
            return NTMessageType.video.rawValue
        case "MESSAGE_TYPE_FILE":
            return NTMessageType.file.rawValue
        case "MESSAGE_TYPE_FIRST_MESSAGE":
            return NTMessageType.firstMessage.rawValue
        case "MESSAGE_TYPE_GROUP_UPDATE":
            return NTMessageType.groupUpdate.rawValue
        case "MESSAGE_TYPE_LEAVE_GROUP":
            return NTMessageType.leaveGroup.rawValue
        case "MESSAGE_TYPE_REPLY":
            return NTMessageType.reply.rawValue
        case "MESSAGE_TYPE_STICKER":
            return NTMessageType.sticker.rawValue
        case "MESSAGE_TYPE_SCREENSHOT":
            return NTMessageType.screenshot.rawValue
        default:
            return NTMessageType.text.rawValue
        }
    }
}

extension RemoteMessage {
    func isFromPrivateGroup() -> Bool {
        return groupType == "GROUP_TYPE_PRIVATE" || groupType == "GROUP_TYPE_PUBLIC" || groupType == "GROUP_TYPE_OFFICIAL"
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "message_id": messageId,
            "group_id": groupId,
            "message": message,
            "sender_uin": senderUin,
            "created_at": createdAt,
//            "message_id": recipientUins,
//            "message_id": seenUins,
//            "message_id": senderName,
//            "message_id": groupName,
//            "message_id": groupType,
            "type": getType(),
            "attachments": attachments,
            "version": version,
            "is_encrypted": isEncrypted,
        ]
    }
}

extension QBMessage {
    init(message: RemoteMessage) throws {
        try self.init(message: NTMessage(data: message.toDictionary()))
    }
    
    public func toString() -> String {
       let encoder = JSONEncoder()
       if let tempData = try? encoder.encode(self) {
           return String.init(data: tempData, encoding: .utf8) ?? ""
       }
       return ""
   }
}

extension NTMessage {
    init(data: [String: Any]) throws {
        let _data: Data = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(NTMessage.self, from: _data)
    }
}

extension RMMessage {
    convenience init(qbMessage: QBMessage) {
        self.init()
        
        self.id = qbMessage.id
        self.senderID = qbMessage.senderID
        self.createdAt = qbMessage.createdAt
        self.expiredAt = qbMessage.expiredAt
        self.dialogID = qbMessage.dialogID
        self.payload = qbMessage.toString()
        
        self.status = qbMessage.status.rawValue
    }
}
