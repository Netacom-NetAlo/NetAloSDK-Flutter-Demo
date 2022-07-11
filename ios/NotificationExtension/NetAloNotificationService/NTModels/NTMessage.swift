//
//  IMMessage.swift
//  NetaloSDK
//
//  Created by Nguyên Duy on 5/18/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public indirect enum NTGroupUpdateType: Codable {
    case updateInfo(String, String) // name, avatar
    case addMembers([String])
    case removeMember(String)
    case changeOwner(String)
    case updateMessageDeleteTimer(Double)
    case updateGroupBackground(NTGroupBackground)

    enum CodingKeys: String, CodingKey {
        case type
        case groupUpdate = "group_update"
        case addedUins = "added_uins"
        case removedUin = "removed_uin"
        case updatedGroupName = "updated_group_name"
        case updatedGroupAvatar = "updated_group_avatar"
        case ownerUin = "owner_uin"
        case updateMessageDeleteTimer = "updated_message_delete_timer"
        case updateGroupBackground = "updated_group_background"
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let addedUins = try? container.decode([String].self, forKey: .addedUins) {
            self = .addMembers(addedUins)
        } else if let removedUin = try? container.decode(String.self, forKey: .removedUin) {
            self = .removeMember(removedUin)
        } else if let ownerUin = try? container.decode(String.self, forKey: .ownerUin) {
            self = .changeOwner(ownerUin)
        } else if let messageDestroyPeriod = try? container.decode(Double.self, forKey: .updateMessageDeleteTimer) {
            self = .updateMessageDeleteTimer(messageDestroyPeriod)
        } else if let background = try? container.decode(NTGroupBackground.self, forKey: .updateGroupBackground){
            self = .updateGroupBackground(background)
        } else {
            let name = container.decodex(key: .updatedGroupName, defaultValue: "")
            let avatar = container.decodex(key: .updatedGroupAvatar, defaultValue: "")
            self = .updateInfo(name, avatar)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        switch self {
        case .addMembers(let uins):
            try container.encode(uins, forKey: .addedUins)
        case .removeMember(let uin):
            try container.encode(uin, forKey: .removedUin)
        case .updateInfo(let name, let avatar):
            try container.encode(name, forKey: .updatedGroupName)
            try container.encode(avatar, forKey: .updatedGroupAvatar)
        case .changeOwner(let uin):
            try container.encode(uin, forKey: .ownerUin)
        case .updateMessageDeleteTimer(let messageDestroyPeriod):
            try container.encode(messageDestroyPeriod, forKey: .updateMessageDeleteTimer)
        case .updateGroupBackground(let url):
            try container.encode(url, forKey: .updateGroupBackground)
        }
    }
    
    private var type: String {
        switch self {
        case .updateInfo:
            return "update_info"
        case .addMembers:
            return "add_member"
        case .removeMember:
            return "remove_member"
        case .changeOwner:
            return "change_owner"
        case .updateMessageDeleteTimer:
            return "updated_message_delete_timer"
        case .updateGroupBackground:
            return "updated_group_background"
        }
    }
    
}

public indirect enum NTMessageKind: Codable {
    
    case unknown
    case text(String)
    case images([NTImage])
    case video(NTVideo)
    case call(NTCall)
    case audio(NTAudio)
    case reply(String, NTMessage)
    case firstMessage
    case groupUpdate(NTGroupUpdateType)
    case leaveGroup(String)
    case forward(String, NTMessage)
    case file(NTFile)
    case sticker(NTSticker)
    case screenshot

    private var type: String {
        switch self {
        case .images:
            return "image"
        case .video:
            return "video"
        case .audio:
            return "audio"
        case .call:
            return "call"
        case .reply:
            return "reply"
        case .firstMessage:
            return "first_message"
        case .groupUpdate:
            return "group_update"
        case .leaveGroup:
            return "leave_group"
        case .text:
            return "text"
        case .forward:
            return "forward"
        case .file:
            return "file"
        case .sticker:
            return "sticker"
        case .screenshot:
            return "screenshot"
        case .unknown:
            return "unknown"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case text, images, call, audio, type, attachments, message, reply, forward, video, file, version, sticker, screenshot
        case firstMessage = "first_message"
        case groupUpdate = "group_update"
        case addedUins = "added_uins"
        case removedUin = "removed_uin"
        case updatedGroupName = "updated_group_name"
        case updatedGroupAvatar = "updated_group_avatar"
        case senderUin = "sender_uin"
        case ownerUin = "owner_uin"
        case updateMessageDeleteTimer = "updated_message_delete_timer"
        case updatedGroupBackground = "updated_group_background"
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    public init(from decoder: Decoder) throws {
        let jDecoder = JSONDecoder()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeValue = container.decodex(key: .type, defaultValue: 0)
        let attachments = container.decodex(key: .attachments, defaultValue: "")
        let messageVersion = container.decodex(key: .version, defaultValue: 0)
        
        guard let data = attachments.data(using: .utf8) else {
            throw CodingError.unknownValue
        }
        
        switch typeValue {
        case NTMessageType.text.rawValue:
            let message = container.decodex(key: .message, defaultValue: "").unescapeString
            self = .text(message)
        case NTMessageType.images.rawValue:
            switch messageVersion {
            case 0:
                let res = try jDecoder.decode(NTImageURLsResponse.self, from: data)
                let images = res.urls.compactMap { NTImage(url: $0, width: 0, height: 0, subIndex: 0) }
                self = .images(images)
            default:
                let res = try jDecoder.decode(NTImageResponse.self, from: data)
                self = .images(res.images)
            }
        case NTMessageType.video.rawValue:
            let res = try jDecoder.decode(NTVideoResponse.self, from: data)
            self = .video(res.video)
        case NTMessageType.call.rawValue:
            let response = try jDecoder.decode(NTCall.self, from: data)
            self = .call(response)
        case NTMessageType.audio.rawValue:
            let response = try jDecoder.decode(NTAudioResponse.self, from: data)
            self = .audio(response.audio)
        case NTMessageType.reply.rawValue:
            let text = container.decodex(key: .message, defaultValue: "")
            let msg = try jDecoder.decode(NTMessage.self, from: data)
            self = .reply(text, msg)
        case NTMessageType.forward.rawValue:
            let text = container.decodex(key: .message, defaultValue: "")
            let msg = try jDecoder.decode(NTMessage.self, from: data)
            self = .forward(text, msg)
        case NTMessageType.firstMessage.rawValue:
            self = .firstMessage
        case NTMessageType.groupUpdate.rawValue:
            let type = try jDecoder.decode(NTGroupUpdateType.self, from: data)
            self = .groupUpdate(type)
        case NTMessageType.leaveGroup.rawValue:
            let senderId = container.decodex(key: .senderUin, defaultValue: "")
            self = .leaveGroup(senderId)
        case NTMessageType.file.rawValue:
            let res = try jDecoder.decode(NTFileResponse.self, from: data)
            self = .file(res.file)
        case NTMessageType.sticker.rawValue:
            let message = try jDecoder.decode(NTSticker.self, from: data)
            self = .sticker(message)
        case NTMessageType.screenshot.rawValue:
            self = .screenshot
        default:
            throw CodingError.unknownValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        switch self {
        case .text(let text):
            try container.encode(text, forKey: .text)
        case .images(let images):
            try container.encode(images, forKey: .images)
        case .video(let video):
            try container.encode(video, forKey: .video)
        case .call(let call):
            try container.encode(call, forKey: .call)
        case .audio(let data):
            try container.encode(data, forKey: .audio)
        case .reply(let text, let message):
            try container.encode(message, forKey: .reply)
            try container.encode(text, forKey: .text)
        case .forward(let text, let message):
            try container.encode(message, forKey: .forward)
            try container.encode(text, forKey: .text)
        case .firstMessage:
            try container.encode("", forKey: .firstMessage)
        case .groupUpdate(let data):
            switch data {
            case .addMembers(let uins):
                try container.encode(uins, forKey: .addedUins)
            case .removeMember(let uin):
                try container.encode(uin, forKey: .removedUin)
            case .updateInfo(let name, let avatar):
                try container.encode(name, forKey: .updatedGroupName)
                try container.encode(avatar, forKey: .updatedGroupAvatar)
            case .changeOwner(let uin):
                try container.encode(uin, forKey: .ownerUin)
            case .updateMessageDeleteTimer(let timer):
                try container.encode(timer, forKey: .updateMessageDeleteTimer)
            case .updateGroupBackground(let background):
                try container.encode(background, forKey: .updatedGroupBackground)
            }
        case .leaveGroup(let uin):
            try container.encode(uin, forKey: .senderUin)
        case .file(let data):
            try container.encode(data, forKey: .file)
        case .sticker(let data):
            try container.encode(data, forKey: .sticker)
        case .unknown, .screenshot:
            break
        }
    }
}

public struct NTMessageList: Codable {
    public let groupID: String
    public let result: Int
    public let pageSize: Int
    public let page: Int
    public let lastMessageID: String
    public var messages: [NTMessage]
    
    enum CodingKeys: String, CodingKey {
        case messages, result
        case lastMessageID = "last_message_id"
        case pageSize = "psize"
        case page = "pindex"
        case groupID = "group_id"
    }
    
    public func codeCheck() -> Bool {
        return result == 0
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        groupID = values.decodex(key: .groupID, defaultValue: "")
        result = values.decodex(key: .result, defaultValue: 0)
        pageSize = values.decodex(key: .pageSize, defaultValue: 0)
        page = values.decodex(key: .page, defaultValue: 0)
        lastMessageID = values.decodex(key: .page, defaultValue: "")
        messages = values.decodex(key: .messages, defaultValue: [])
    }
}

struct NTMessageResponse: Codable {
    let result: Int
    let message: NTMessage?
    
    enum CodingKeys: String, CodingKey {
        case message, result
    }
    
    public func codeCheck() -> Bool {
        return result == 0
    }
    
    public func duplicateCode() -> Bool {
        return result == 13
    }
}

public enum NTMessageType: Int {
    case text = 0
    case call = 1
    case images = 2
    case audio = 3
    case video = 4
    case firstMessage = 5
    case groupUpdate = 6
    case leaveGroup = 7
    case reply = 8
    case forward = 9
    case sticker = 10
    case file = 12
    case screenshot = 13
    
    public var typeName: String {
        switch self {
        case .text: return "text"
        case .call: return "call"
        case .images: return "image"
        case .audio: return "audio"
        case .video: return "video"
        case .firstMessage: return "first_message"
        case .groupUpdate: return "group_update"
        case .leaveGroup: return "leave_group"
        case .reply: return "reply"
        case .forward: return "forward"
        case .sticker: return "sticker"
        case .file: return "file"
        case .screenshot: return "screenshot"
        }
    }
}

public struct NTMessage: Codable {
    public var send_uin: Double
    public var recv_uin: Double
    
    public var groupAvatar, senderName, senderAvatar: String
    public var groupID: String
    public var status: Int
    public var seenUins: [String]
    public var receivedUins: [String]
    public var mentionedUins: [String]
    public var mentionedAll: Bool
    public var messageID, createdAt, senderUin: String
    public var message: String
    public var recipientUins: [String]
    public var updatedAt: UInt64
    public var deletedUins: [String]
    public var groupName: String
    public var type: Int
    public var attachments: String
    public var version: Int
    public var isEncrypted: Bool
    
    public var kind: NTMessageKind
    
    public var messageType: NTMessageType {
        return NTMessageType(rawValue: type) ?? .text
    }
    
    enum CodingKeys: String, CodingKey {
        case send_uin, recv_uin, status, message, attachments, type, version
        case seenUins = "seen_uins"
        case groupID = "group_id"
        case receivedUins = "received_uins"
        case messageID = "message_id"
        case createdAt = "created_at"
        case senderUin = "sender_uin"
        case recipientUins = "recipient_uins"
        case updatedAt = "updated_at"
        case deletedUins = "deleted_uins"
        case groupAvatar = "group_avatar"
        case senderName = "sender_name"
        case senderAvatar = "sender_avatar"
        case groupName = "group_name"
        case isEncrypted = "is_encrypted"
        case mentionedUins = "mentioned_uins"
        case mentionedAll = "mentioned_all"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(groupAvatar, forKey: .groupAvatar)
        try container.encode(senderName, forKey: .senderName)
        try container.encode(senderAvatar, forKey: .senderAvatar)
        try container.encode(groupID, forKey: .groupID)
        try container.encode(status, forKey: .status)
        try container.encode(seenUins, forKey: .seenUins)
        try container.encode(receivedUins, forKey: .receivedUins)
        try container.encode(messageID, forKey: .messageID)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(senderUin, forKey: .senderUin)
        try container.encode(message, forKey: .message)
        try container.encode(recipientUins, forKey: .recipientUins)
        try container.encode(deletedUins, forKey: .deletedUins)
        try container.encode(groupName, forKey: .groupName)
        try container.encode(type, forKey: .type)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(version, forKey: .version)
        try container.encode(isEncrypted, forKey: .isEncrypted)
        try container.encode(mentionedUins, forKey: .mentionedUins)
        try container.encode(mentionedAll, forKey: .mentionedAll)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = values.decodex(key: .message, defaultValue: "")
        send_uin = values.decodex(key: .send_uin, defaultValue: 0)
        recv_uin = values.decodex(key: .recv_uin, defaultValue: 0)

        groupID = values.decodex(key: .groupID, defaultValue: "")
        status = values.decodex(key: .status, defaultValue: 1)
        seenUins = values.decodex(key: .seenUins, defaultValue: [])
        receivedUins = values.decodex(key: .receivedUins, defaultValue: [])
        messageID = values.decodex(key: .messageID, defaultValue: "")
        createdAt = values.decodex(key: .createdAt, defaultValue: "")
        senderUin = values.decodex(key: .senderUin, defaultValue: "")
        recipientUins = values.decodex(key: .recipientUins, defaultValue: [])
        updatedAt = values.decodex(key: .updatedAt, defaultValue: 0)
        deletedUins = values.decodex(key: .deletedUins, defaultValue: [])
        attachments = values.decodex(key: .attachments, defaultValue: "")
        type = values.decodex(key: .type, defaultValue: 0)
        version = values.decodex(key: .version, defaultValue: 0)
        groupAvatar = values.decodex(key: .groupAvatar, defaultValue: "")
        senderName = values.decodex(key: .senderName, defaultValue: "")
        senderAvatar = values.decodex(key: .senderAvatar, defaultValue: "")
        groupName = values.decodex(key: .groupName, defaultValue: "")
        isEncrypted = values.decodex(key: .isEncrypted, defaultValue: false)
        mentionedUins = values.decodex(key: .mentionedUins, defaultValue: [])
        mentionedAll = values.decodex(key: .mentionedAll, defaultValue: false)
        
        if let _kind = try? NTMessageKind(from: decoder) {
            kind = _kind
        } else {
            kind = .unknown
        }
        
        // Check seconds convert to miliseconds
        if let _createdAt = Double(createdAt),  _createdAt / pow(10, 10) < 1 {
            createdAt = String(_createdAt * pow(10, 6))
        }
    }
    
    /// For sending message
    public init(messageID: String = "", groupID: String, message: String, senderName: String, senderAvatar: String, senderUin: String, isEncrypted: Bool) {
        self.messageID = messageID
        self.message = message
        self.groupID = groupID
        self.senderName = senderName
        self.senderAvatar = senderAvatar
        self.senderUin = senderUin

        self.send_uin = 0
        self.recv_uin = 0
        
        self.status = 0
        self.seenUins = []
        self.receivedUins = []
        self.createdAt = ""
        self.recipientUins = []
        self.updatedAt = 0
        self.deletedUins = []
        self.attachments = ""
        self.kind = .text(message)
        self.type = 0
        self.groupAvatar = ""
        self.groupName = ""
        self.version = 0
        self.mentionedUins = []
        self.mentionedAll = false
        self.isEncrypted = isEncrypted
    }
    
    public func toString() -> String {
        let encoder = JSONEncoder()
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
}
