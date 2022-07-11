//
//  IMConversation.swift
//  NetaloSDK
//
//  Created by Nguyên Duy on 5/18/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

// MARK: - IMConversationsList
public struct NTConversationList: Codable {
    public let result: Int
    public let pageSize: Int?
    public let page: Int?
    public let conversations: [NTConversation]
    
    func codeCheck() -> Bool {
        return result == 0
    }
    
    enum CodingKeys: String, CodingKey {
        case result
        case pageSize = "psize"
        case page = "pindex"
        case conversations = "groups"
    }
}

struct NTConversationResponse: Codable {
    let result: Int
    let conversation: NTConversation?
    
    enum CodingKeys: String, CodingKey {
        case result
        case conversation = "group"
    }
    
    func codeCheck() -> Bool {
        return result == 0
    }
}

// MARK: - NTLastActionMessage

public struct NTLastActiveMessage: Codable {
    public let uin: String
    public let messageId: String
    
    enum CodingKeys: String, CodingKey {
        case uin = "uin"
        case messageId = "message_id"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.uin = values.decodex(key: .uin, defaultValue: "")
        self.messageId = values.decodex(key: .messageId, defaultValue: "")
    }
}

// MARK: - IMConversation
public struct NTConversation: Codable {
    public let occupantsUins, blockedUins, mutedUins: [String]
    public let receivedList, seenList: [String: String]
    public let groupID, createdAt, lastMessageID, avatarUrl: String
    public let type: Int
    public let updatedAt, name: String
    public var ownerUin, creatorUin: String
    public var addedUins: [String] = []
    public var removedUins: [String] = []
    public var unblockedUins: [String] = []
    public var lastMessage: NTMessage?
    public var statusList: [NTUserStatus]
    public var pinnedUins: [String] = []
    public var secrets: [NTSecretChat] = []
    public var lastActiveMessages: [NTLastActiveMessage] = []
    public var background: NTGroupBackground
    
    enum CodingKeys: String, CodingKey {
        case occupantsUins = "occupants_uins"
        case groupID = "group_id"
        case createdAt = "created_at"
        case lastMessageID = "last_message_id"
        case ownerUin = "owner_uin"
        case type, name, secrets, background
        case updatedAt = "updated_at"
        case avatarUrl = "avatar_url"
        case receivedList = "received_list"
        case seenList = "seen_list"
        case blockedUins = "blocked_uins"
        case lastMessage = "last_message"
        case statusList = "status_list"
        case mutedUins = "muted_uins"
        case removedUins = "removed_uins"
        case creatorUin = "creator_uin"
        case pinnedUins = "pinned_uins"
        case lastActiveMessages = "last_active_messages"
    }
    
    // Receive update group
    init(groupUpdate: NTGroupUpdate) {
        self.groupID = groupUpdate.groupID
        self.name = groupUpdate.name
        self.avatarUrl = groupUpdate.avatarUrl
        self.addedUins = groupUpdate.addedUins
        self.removedUins = groupUpdate.removedUins
        self.blockedUins = groupUpdate.blockedAll
        self.unblockedUins = groupUpdate.unblockedAll
        self.ownerUin = groupUpdate.ownerUin
        self.background = groupUpdate.background
        
        self.occupantsUins = []
        self.createdAt = ""
        self.lastMessageID = ""
        self.type = 0
        self.updatedAt = ""
        self.receivedList = [:]
        self.seenList = [:]
        self.statusList = []
        self.mutedUins = []
        self.creatorUin = ""
        self.pinnedUins = []
        self.secrets = []
        self.lastActiveMessages = []
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        groupID = values.decodex(key: .groupID, defaultValue: "")
        name = values.decodex(key: .name, defaultValue: "")
        avatarUrl = values.decodex(key: .avatarUrl, defaultValue: "")
        ownerUin = values.decodex(key: .ownerUin, defaultValue: "")
        occupantsUins = values.decodex(key: .occupantsUins, defaultValue: [])
        createdAt = values.decodex(key: .createdAt, defaultValue: "")
        lastMessageID = values.decodex(key: .lastMessageID, defaultValue: "")
        type = values.decodex(key: .type, defaultValue: 0)
        updatedAt = values.decodex(key: .updatedAt, defaultValue: "")
        let _receivedList: [NTGroupMessageStatus] = values.decodex(key: .receivedList, defaultValue: [])
        let _seenList: [NTGroupMessageStatus] = values.decodex(key: .seenList, defaultValue: [])
        seenList = Dictionary(uniqueKeysWithValues: _seenList.map { ($0.uin, $0.messageID) })
        receivedList = Dictionary(uniqueKeysWithValues: _receivedList.map { ($0.uin, $0.messageID) })
        lastMessage = try? values.decode(NTMessage.self, forKey: .lastMessage)
        statusList = try values.decode([NTUserStatus].self, forKey: .statusList)
        mutedUins = values.decodex(key: .mutedUins, defaultValue: [])
        removedUins = values.decodex(key: .removedUins, defaultValue: [])
        creatorUin = values.decodex(key: .creatorUin, defaultValue: ownerUin)
        secrets = values.decodex(key: .secrets, defaultValue: [])

        addedUins = []
        blockedUins = values.decodex(key: .blockedUins, defaultValue: [])
        unblockedUins = []
        self.pinnedUins = values.decodex(key: .pinnedUins, defaultValue: [])
        self.lastActiveMessages = values.decodex(key: .lastActiveMessages, defaultValue: [])
        let backgroundString = values.decodex(key: .background, defaultValue: "").unescapeString
        if backgroundString.count > 0, let data = backgroundString.data(using: .utf8) {
            self.background = try JSONDecoder().decode(NTGroupBackground.self, from: data)
        } else {
            self.background = values.decodex(key: .background, defaultValue: NTGroupBackground(backgroundUrl: "", isBlur: false))
        }
    }
}

public struct NTGroupMessageStatus: Codable {
    public let uin, messageID: String

    enum CodingKeys: String, CodingKey {
        case uin
        case messageID = "message_id"
    }
}

struct NTGroupUpdate: Codable {
    let name, avatarUrl, ownerUin, groupID: String
    let removedUins, addedUins, blockedAll, unblockedAll: [String]
    let background: NTGroupBackground

    enum CodingKeys: String, CodingKey {
        case name, background
        case groupID = "group_id"
        case ownerUin = "owner_uin"
        case avatarUrl = "avatar_url"
        case removedUins = "pull_all"
        case addedUins = "push_all"
        case blockedAll = "blocked_all"
        case unblockedAll = "unblocked_all"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = values.decodex(key: .name, defaultValue: "")
        avatarUrl = values.decodex(key: .avatarUrl, defaultValue: "")
        ownerUin = values.decodex(key: .ownerUin, defaultValue: "")
        groupID = values.decodex(key: .groupID, defaultValue: "")
        removedUins = values.decodex(key: .removedUins, defaultValue: [])
        addedUins = values.decodex(key: .addedUins, defaultValue: [])
        blockedAll = values.decodex(key: .blockedAll, defaultValue: [])
        unblockedAll = values.decodex(key: .unblockedAll, defaultValue: [])
        let backgroundString = values.decodex(key: .background, defaultValue: "").unescapeString
        if backgroundString.count > 0, let data = backgroundString.data(using: .utf8) {
            self.background = try JSONDecoder().decode(NTGroupBackground.self, from: data)
        } else {
            self.background = values.decodex(key: .background, defaultValue: NTGroupBackground(backgroundUrl: "", isBlur: false))
        }
    }
}
