//
//  QBMessage.swift
//  Netalo
//
//  Created by Tran Phong on 1/8/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

enum QBMessageType: String {
    case text  = "text"
    case audio = "audio"
    case image = "image"
    case reply = "reply"
    case video = "video"
    case file  = "file"
    case sticker = "sticker"
    case screenshot = "screenshot"
}

public indirect enum QBGroupUpdateType: Codable {
    case updateInfo(String, String) // name, avatar
    case addMembers([String])
    case removeMember(String)
    case changeOwner(String)
    case updateMessageDeleteTimer(Double)
    case updatedGroupBackground(QBGroupBackground)

    enum CodingKeys: String, CodingKey {
        case type
        case groupUpdate = "group_update"
        case addedUins = "added_uins"
        case removedUin = "removed_uin"
        case updatedGroupName = "updated_group_name"
        case updatedGroupAvatar = "updated_group_avatar"
        case ownerUin = "owner_uin"
        case updateMessageDeleteTimer = "updated_message_delete_timer"
        case updatedGroupBackground = "updated_group_background"
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
        } else if let background = try? container.decode(QBGroupBackground.self, forKey: .updatedGroupBackground) {
            self = .updatedGroupBackground(background)
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
        case .updatedGroupBackground(let background):
            try container.encode(background, forKey: .updatedGroupBackground)
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
        case .updatedGroupBackground:
            return "updated_group_background"
        }
    }

    init(type: NTGroupUpdateType) {
        switch type {
        case .addMembers(let uins): self = .addMembers(uins)
        case .removeMember(let uin): self = .removeMember(uin)
        case .updateInfo(let name, let avatar): self = .updateInfo(name, avatar)
        case .changeOwner(let uin): self = .changeOwner(uin)
        case .updateMessageDeleteTimer(let timer): self = .updateMessageDeleteTimer(timer)
        case .updateGroupBackground(let background): self = .updatedGroupBackground(QBGroupBackground(backgroundUrl: background.backgroundUrl, isBlur: background.isBlur))
        }
    }
}

indirect enum QBMessageKind: Codable {
    
    case unknown
    case text(String)
    case imageStrings([String])
    case images([QBImage])
    case video(QBVideo)
    case call(QBCall)
    case audio(QBAudio)
    case reply(String, QBMessage)
    case forward(String, QBMessage)
    case firstMessage
    case groupUpdate(QBGroupUpdateType)
    case leaveGroup(String)
    case file(QBFile)
    case sticker(QBSticker)
    case screenshot

    enum Key: String, CodingKey {
        case type, text, images, video, call, audio, file, sticker, screenshot
        case reply = "origin_message"
        case _reply = "reply"
        case forward = "forward"
        case firstMessage = "first_message"
        case groupUpdate = "group_update"
        case addedUins = "added_uins"
        case removedUin = "removed_uin"
        case updatedGroupName = "updated_group_name"
        case updatedGroupAvatar = "updated_group_avatar"
        case senderUin = "sender_uin"
        case ownerUin = "owner_uin"
        case updateMessageDeleteTimer = "updated_message_delete_timer"
        case updateGroupBackground = "updated_group_background"
    }

    enum CodingError: Error {
        case unknownValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let typeValue = container.decodex(key: .type, defaultValue: "text")
        switch typeValue {
        case "text":
            let text = container.decodex(key: .text, defaultValue: "")
            self = .text(text)
        case "image":
            let urls: [String] = container.decodex(key: .images, defaultValue: [])
            if urls.count > 0 {
                self = .imageStrings(urls)
            } else {
                let images: [QBImage] = container.decodex(key: .images, defaultValue: [])
                self = .images(images)
            }
        case "video":
            if let data = try? container.decode(QBVideo.self, forKey: .video) {
                self = .video(data)
            } else {
                self = .unknown
            }
        case "call":
            if let call = try? container.decode(QBCall.self, forKey: .call) {
                self = .call(call)
            } else {
                self = .unknown
            }
        case "audio":
            if let data = try? container.decode(QBAudio.self, forKey: .audio) {
                self = .audio(data)
            } else {
                self = .unknown
            }
        case "reply":
            let text = container.decodex(key: .text, defaultValue: "")
            if let data = try? container.decode(QBMessage.self, forKey: ._reply) {
                self = .reply(text, data)
            } else if let data = try? container.decode(QBMessage.self, forKey: .reply) {
                self = .reply(text, data)
            } else {
                self = .unknown
            }
        case "forward":
            let text = container.decodex(key: .text, defaultValue: "")
            if let data = try? container.decode(QBMessage.self, forKey: .forward) {
                self = .forward(text, data)
            } else {
                self = .unknown
            }
        case "group_update":
            let type = try QBGroupUpdateType(from: decoder)
            self = .groupUpdate(type)
        case "leave_group":
            let id = container.decodex(key: .senderUin, defaultValue: "")
            self = .leaveGroup(id)
        case "first_message":
            self = .firstMessage
        case "file":
            if let data = try? container.decode(QBFile.self, forKey: .file) {
                self = .file(data)
            } else {
                self = .unknown
            }
        case "sticker":
            if let sticker = try? container.decode(QBSticker.self, forKey: .sticker) {
                self = .sticker(sticker)
            } else {
                self = .unknown
            }
        case "screenshot":
            self = .screenshot
        default:
            self = .unknown
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(type(), forKey: .type)

        switch self {
        case .text(let text):
            try container.encode(text, forKey: .text)
        case .images(let images):
            try container.encode(images, forKey: .images)
        case .imageStrings(let urls):
            try container.encode(urls, forKey: .images)
        case .video(let data):
            try container.encode(data, forKey: .video)
        case .call(let call):
            try container.encode(call, forKey: .call)
        case .audio(let data):
            try container.encode(data, forKey: .audio)
        case .reply(let text, let data):
            try container.encode(data, forKey: .reply)
            try container.encode(text, forKey: .text)
        case .forward(let text, let data):
            try container.encode(data, forKey: .forward)
            try container.encode(text, forKey: .text)
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
            case .updatedGroupBackground(let url):
                try container.encode(url, forKey: .updateGroupBackground)
            }
        case .file(let data):
            try container.encode(data, forKey: .file)
        case .sticker(let text):
            try container.encode(text, forKey: .sticker)
        default:
            break
        }
    }

    func type() -> String {
        switch self {
        case .text:
            return "text"
        case .images, .imageStrings:
            return "image"
        case .video:
            return "video"
        case .call:
            return "call"
        case .audio:
            return "audio"
        case .reply:
            return "reply"
        case .forward:
            return "forward"
        case .firstMessage:
            return "first_message"
        case .groupUpdate:
            return "group_update"
        case .leaveGroup:
            return "leave_group"
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
    
    var typeInt: Int {
        switch self {
        case .text:
            return 0
        case .call:
            return 1
        case .images, .imageStrings:
            return 2
        case .audio:
            return 3
        case .video:
            return 4
        case .firstMessage:
            return 5
        case .groupUpdate:
            return 6
        case .leaveGroup:
            return 7
        case .reply:
            return 8
        case .forward:
            return 9
        case .sticker:
            return 10
        case .file:
            return 12
        case .screenshot:
            return 13
        case .unknown:
            return -1
        }
    }

    public func toString() -> String {
        let encoder = JSONEncoder()
        if case .sticker(let data) = self {
            if let tempData = try? encoder.encode(data) {
                return String.init(data: tempData, encoding: .utf8) ?? ""
            }
        }
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
    
    public func stickerToString() -> String {
        if case .sticker(let data) = self {
            let encoder = JSONEncoder()
            if let tempData = try? encoder.encode(data) {
                return String.init(data: tempData, encoding: .utf8) ?? ""
            }
        }
        return ""
    }
}


struct QBCall: Codable {
    public let id: String
    public let groupID: String
    public let mediaType: Int
    public let callStatus: Int
    public var callerUin: String
    public let calleeUins: [String]
    public var acceptedUins: [String]
    public let startedAt: UInt
    public var stoppedAt: UInt
    public var answeredAt: UInt
    public var connectedAt: UInt
    public var duration: UInt = 0
    public var type: String

    enum CodingKeys: String, CodingKey {
        case id = "call_id"
        case groupID = "group_id"
        case type = "call_type"
        case mediaType = "media_type"
        case callStatus = "call_status"
        case callerUin = "caller_uin"
        case calleeUins = "callee_uins"
        case acceptedUins = "accepted_uins"
        case startedAt = "started_at"
        case stoppedAt = "stopped_at"
        case answeredAt = "accepted_at"
        case connectedAt = "connected_at"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodex(key: .id, defaultValue: "")
        groupID = values.decodex(key: .groupID, defaultValue: "")
        mediaType = values.decodex(key: .mediaType, defaultValue: 0)
        callStatus = values.decodex(key: .callStatus, defaultValue: 0)

        callerUin = values.decodex(key: .callerUin, defaultValue: "")
        calleeUins = values.decodex(key: .calleeUins, defaultValue: [])
        acceptedUins = values.decodex(key: .acceptedUins, defaultValue: [])
        
        let _connectedAt = values.decodex(key: .connectedAt, defaultValue: "")
        connectedAt = UInt(_connectedAt) ?? 0

        let prefix = mediaType == NTCall.MEDIA_TYPE_AUDIO ? "voice" : "video"
        let suffix = connectedAt != 0 ? "success" : "missed"
        type = prefix + "_" + suffix

        let _startedAt = values.decodex(key: .startedAt, defaultValue: "")
        startedAt = UInt(_startedAt) ?? 0
        let _stoppedAt = values.decodex(key: .stoppedAt, defaultValue: "")
        stoppedAt = UInt(_stoppedAt) ?? 0
        
        let _answeredAt = values.decodex(key: .answeredAt, defaultValue: "")
        answeredAt = UInt(_answeredAt) ?? 0
        answeredAt = answeredAt == 0 ? startedAt : answeredAt
        
        duration = connectedAt != 0 ? stoppedAt - connectedAt : 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(groupID, forKey: .groupID)
        try container.encode(mediaType, forKey: .mediaType)
        try container.encode(callerUin, forKey: .callerUin)
        try container.encode(acceptedUins, forKey: .acceptedUins)
        try container.encode(calleeUins, forKey: .calleeUins)
        try container.encode(callStatus, forKey: .callStatus)
        try container.encode(String(startedAt), forKey: .startedAt)
        try container.encode(String(stoppedAt), forKey: .stoppedAt)
        try container.encode(String(answeredAt), forKey: .answeredAt)
        try container.encode(String(connectedAt), forKey: .connectedAt)
    }
    
}

struct QBAudio: Codable {
    let url: String
    let duration: UInt

    init(url: String, duration: UInt) {
        self.url = url
        self.duration = duration
    }

    var publicUrl: String {
        return NetAloBuildConfig.default.imageUrl + url
    }

    func toString() -> String {
        let encoder = JSONEncoder()
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
}

struct QBImage: Codable {
    let url: String
    let width: UInt?
    let height: UInt?
    let subIndex: UInt?
    
    enum CodingKeys: String, CodingKey {
        case url, width, height
        case subIndex = "sub_index"
    }

    init(url: String, width: UInt?, height: UInt?, subIndex: UInt?) {
        self.url = url
        self.width = width
        self.height = height
        self.subIndex = subIndex
    }

    func toString() -> String {
        let encoder = JSONEncoder()
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = container.decodex(key: .url, defaultValue: "")
        width = container.decodex(key: .width, defaultValue: 0)
        height = container.decodex(key: .height, defaultValue: 0)
        subIndex = container.decodex(key: .subIndex, defaultValue: 0)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try? container.encode(width, forKey: .width)
        try? container.encode(height, forKey: .height)
        try? container.encode(subIndex, forKey: .subIndex)
    }
}

struct QBImageResponse: Codable {
    public let images: [QBImage]
    
    enum CodingKeys: String, CodingKey {
        case images = "images"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        images = container.decodex(key: .images, defaultValue: [])
    }
}

struct QBImageURLsResponse: Codable {
    public let urls: [String]
    
    enum CodingKeys: String, CodingKey {
        case urls = "images"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        urls = container.decodex(key: .urls, defaultValue: [])
    }
}
    
public struct QBVideo: Codable {
    let url: String
    let duration: UInt
    let width: UInt
    let height: UInt
    var thumbnailUrl: String
    var publicUrl: String {
        return NetAloBuildConfig.default.imageUrl + url
    }
    var shouldCompress: Bool?
    
    enum CodingKeys: String, CodingKey {
        case url, duration, width, height
        case thumbnailUrl = "thumbnail_url"
    }

    init(url: String, thumbnailUrl: String, duration: UInt, width: UInt, height: UInt) {
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.duration = duration
        self.width = width
        self.height = height
    }

    func toString() -> String {
        let encoder = JSONEncoder()
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
}

struct QBVideoResponse: Codable {
    let video: QBVideo
}

struct QBSticker: Codable {
    var sticker: String
}

public struct QBFile: Codable {
    var url: String
    let fileName: String
    let fileExtension: String
    let size: Double
    
    var publicUrl: String {
        return NetAloBuildConfig.default.imageUrl + url
    }
    
    var fullFileName: String {
        let suffix = "." + fileExtension
        if fileName.contains(suffix) {
            return fileName
        } else {
            return fileName + suffix
        }
    }
    
    var fileSizeString: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(size)).replacingOccurrences(of: ",", with: ".")
    }
    
    var mimeType: String {
        switch fileExtension {
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "pdf":
            return "application/pdf"
        default:
            return ""
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case url, size
        case fileName = "file_name"
        case fileExtension = "file_extension"
    }

    init(url: String, fileName: String, fileExtension: String, size: Double) {
        self.url = url
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.size = size
    }

    func toString() -> String {
        let encoder = JSONEncoder()
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
}

struct QBFileResponse: Codable {
    let file: QBFile
}

public enum QBMessageStatus: String {
    case sending = "sending"
    case sent = "sent"
    case received = "received"
    case seen = "seen"
    case failed = "failed"
    case deleted = "deleted"

    var intValue: Int {
        switch self {
        case .sending: return 0
        case .sent: return 1
        case .received: return 2
        case .seen: return 3
        case .deleted: return 4
        case .failed: return -1
        }
    }

    init(intValue: Int) {
        switch intValue {
        case 0: self = .sending
        case 1: self = .sent
        case 2: self = .received
        case 3: self = .seen
        case 4: self = .deleted
        default: self = .failed
        }
    }
}

public struct QBMessage: Codable {
    public var id: String
    public var qbId: String
    var _status: String
    public var status: QBMessageStatus
    public var createdAt: Double
    public var expiredAt: Double
    public var timeToLive: Double
    public var deliveredAt: Double
    public var senderID: String
    public var dialogID: String
    var receiverUsername: String
    var kind: QBMessageKind
    public var sendType: String
    public var groupAvatar, senderName, senderAvatar: String
    public var version: Int
    public var isEncrypted: Bool
    public var isDecrypted: Bool
    public var message: String = ""
    public var type: Int {
        switch kind {
        case .text: return 0
        case .call: return 1
        case .images: return 2
        case .audio: return 3
        default: return -1
        }
    }
    public var seenUins, receivedUins, deletedUins, mentionedUins: [String]
    public var mentionedAll: Bool
    
    var createdAtSeconds: Double {
        return createdAt / pow(10,6)
    }

    enum CodingKeys: String, CodingKey {
        case id = "message_id"
        case createdAt = "created_at"
        case kind, status, _status, qbId, version
        case senderID = "sender_uin"
        case dialogID = "group_id"
        case receiverUsername = "receiver_username"
        case expiredAt = "expired_at"
        case deliveredAt = "delivered_at"
        case timeToLive = "time_to_live"
        case sendType = "send_type"
        case groupAvatar = "group_avatar"
        case senderName = "sender_name"
        case senderAvatar = "sender_avatar"
        case message, type
        case seenUins = "seen_uins"
        case receivedUins = "received_uins"
        case deletedUins = "deleted_uins"
        case isEncrypted = "is_encrypted"
        case isDecrypted = "is_decrypted"
        case mentionedUins = "mentioned_uins"
        case mentionedAll = "mentioned_all"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodex(key: .id, defaultValue: "")
        createdAt = values.decodex(key: .createdAt, defaultValue: 0)
        senderID = values.decodex(key: .senderID, defaultValue: "")
        dialogID = values.decodex(key: .dialogID, defaultValue: "")
        deletedUins = values.decodex(key: .deletedUins, defaultValue: [])
        version = values.decodex(key: .version, defaultValue: 0)
        let statusCode = values.decodex(key: .status, defaultValue: 1)
        status = QBMessageStatus(intValue: statusCode)
        self._status = status.rawValue
        kind = try QBMessageKind(from: decoder)
        receiverUsername = values.decodex(key: .receiverUsername, defaultValue: "")
        qbId = values.decodex(key: .qbId, defaultValue: "")
        expiredAt = values.decodex(key: .expiredAt, defaultValue: 0)
        deliveredAt = values.decodex(key: .deliveredAt, defaultValue: 0)
        timeToLive = values.decodex(key: .timeToLive, defaultValue: 0)
        sendType = values.decodex(key: .sendType, defaultValue: "personal")
        groupAvatar = values.decodex(key: .groupAvatar, defaultValue: "")
        senderName = values.decodex(key: .senderName, defaultValue: "")
        senderAvatar = values.decodex(key: .senderAvatar, defaultValue: "")
        if case .text(let content) = kind { message = content }
        seenUins = values.decodex(key: .seenUins, defaultValue: [])
        receivedUins = values.decodex(key: .receivedUins, defaultValue: [])
        isEncrypted = values.decodex(key: .isEncrypted, defaultValue: false)
        isDecrypted = false
        mentionedUins = values.decodex(key: .mentionedUins, defaultValue: [])
        mentionedAll = values.decodex(key: .mentionedAll, defaultValue: false)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(senderID, forKey: .senderID)
        try container.encode(dialogID, forKey: .dialogID)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(expiredAt, forKey: .expiredAt)
        try container.encode(deliveredAt, forKey: .deliveredAt)
        try container.encode(timeToLive, forKey: .timeToLive)
        try container.encode(receiverUsername, forKey: .receiverUsername)
        try container.encode(status.intValue, forKey: .status)
        try container.encode(status.rawValue, forKey: ._status)
        try container.encode(qbId, forKey: .qbId)
        try container.encode(groupAvatar, forKey: .groupAvatar)
        try container.encode(senderName, forKey: .senderName)
        try container.encode(senderAvatar, forKey: .senderAvatar)
        try container.encode(type, forKey: .type)
        try container.encode(seenUins, forKey: .seenUins)
        try container.encode(deletedUins, forKey: .deletedUins)
        try container.encode(receivedUins, forKey: .receivedUins)
        try container.encode(version, forKey: .version)
        try container.encode(isEncrypted, forKey: .isEncrypted)
        try container.encode(isDecrypted, forKey: .isDecrypted)
        try container.encode(mentionedUins, forKey: .mentionedUins)
        try container.encode(mentionedAll, forKey: .mentionedAll)
        if case .text(let content) = kind { try container.encode(content, forKey: .message) }
        try kind.encode(to: encoder)
    }

    public init(message: NTMessage) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(QBMessage.self, from: message.toString().data(using: .utf8) ?? Data())
        self.createdAt = Double(message.createdAt) ?? 0
        self.deliveredAt = 0
        self.expiredAt = 0
        
        if message.status == 0 {
            self.status = .sent
        } else {
            self.status = QBMessageStatus(intValue: message.status)
        }
        self._status = self.status.rawValue
        self.kind = .text(message.message)
        if let data = try? JSONEncoder().encode(message.kind) {
            self.kind = try decoder.decode(QBMessageKind.self, from: data)
        }

        if type == NTMessageType.firstMessage.rawValue {
            self.kind = .firstMessage
        } else if type == NTMessageType.leaveGroup.rawValue {
            self.kind = .leaveGroup(message.senderUin)
        }
        
        switch message.kind {
        case .reply(let text, let  data):
            if let msg = try? QBMessage(message: data) {
                self.kind = .reply(text, msg)
            }
            
        case .forward(let text, let data):
            if let msg = try? QBMessage(message: data) {
                self.kind = .forward(text, msg)
            }
            
        default:
            break
        }
    }
}
