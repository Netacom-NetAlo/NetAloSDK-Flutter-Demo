//
//  LocalRepo.swift
//  NotificationExtention
//
//  Created by Tran Phong on 7/3/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import RealmSwift

protocol LocalRepo {
    func getConversation(id: String) -> RMConversation?
    func updateConversationName(id: String, conversationName: String)
    func updateConversationBackground(id: String, background: QBGroupBackground)
    func updateConversationAvatarUrl(id: String, avatarUrl: String)
    func updateMembersToConversation(id: String, memberIds: [String])
    func removeMemberInConversation(id: String, memberId: String)
    func changeOwnerOfConversation(id: String, ownerId: String)
    func getContact(id: String) -> RMContact?
    func getContacts(ids: [String]) -> Results<RMContact>?
    func saveMessage(_ message: RMMessage)
    func getUnreadConversationsAndMissedCalls() -> Int
    func removeConversation(id: String)
    func getCurrentUser() -> RMUser?
    func saveReceiverMessageTimeToLive(groupId: String, messageTimeToLive: Double)
}

class LocalRepoImpl: LocalRepo {
    private var databaseVersion: UInt64 = NetAloBuildConfig.default.databaseVersion
    private let availableObjectTypes = [RMConversation.self, RMContact.self, RMLocalContact.self, RMMessage.self, RMUser.self, RMUserStatus.self]
    
    private var realm: Realm? {
        return try? Realm(configuration: realmConfig)
    }
    private let realmConfig: Realm.Configuration
    
    public init() {
        // Limit tables because memory limit in extension
        var configuration = Realm.Configuration(
            schemaVersion: self.databaseVersion,
            objectTypes: self.availableObjectTypes
        )
        
        // Set container to app group
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: NetAloBuildConfig.default.appGroupIdentifier)
        if let realmURL = container?.appendingPathComponent(NetAloBuildConfig.default.databaseIdentifier) {
            configuration = Realm.Configuration(
                fileURL: realmURL,
                schemaVersion: self.databaseVersion,
                objectTypes: self.availableObjectTypes
            )
        }
        
        self.realmConfig = configuration
    }
    
    // RMConversation
    func getConversation(id: String) -> RMConversation? {
        return realm?
            .objects(RMConversation.self)
            .filter("id == '\(id)'")
            .first
    }
    
    func removeConversation(id: String) {
        if let convs = realm?
            .objects(RMConversation.self)
            .filter("id == '\(id)'") {
            
            try? realm?.write {
                self.realm?.delete(convs)
            }
        }
    }
    
    func updateConversationName(id: String, conversationName: String) {
        try? realm?.write {
            if let conversation = realm?.objects(RMConversation.self)
                                .filter("id == '\(id)'")
                                .first {
                conversation.displayName = conversationName
            }
        }
    }
    
    func updateConversationBackground(id: String, background: QBGroupBackground) {
        try? realm?.write {
            if let conversation = realm?.objects(RMConversation.self)
                .filter("id == '\(id)'")
                .first {
                conversation.backgroundUrl = background.backgroundUrl
                conversation.isBlur = background.isBlur
            }
        }
    }
    
    func updateConversationAvatarUrl(id: String, avatarUrl: String) {
        try? realm?.write {
            if let conversation = realm?.objects(RMConversation.self)
                                .filter("id == '\(id)'")
                                .first {
                conversation.avatarUrl = avatarUrl
            }
        }
    }
    
    func updateMembersToConversation(id: String, memberIds: [String]) {
        let memberIdsString = memberIds.joined(separator: ",")
        try? realm?.write {
            if let conversation = realm?.objects(RMConversation.self)
                                .filter("id == '\(id)'")
                                .first {
                conversation.userIds = memberIdsString
            }
        }
    }
    
    func removeMemberInConversation(id: String, memberId: String) {
        try? realm?.write {
            if let conversation = realm?.objects(RMConversation.self)
                                .filter("id == '\(id)'")
                                .first {
                var userIds = conversation.userIds.components(separatedBy: ",")
                if let userNeedRemoveIndex = userIds.index(of: memberId) {
                    userIds.remove(at: userNeedRemoveIndex)
                    
                    conversation.userIds = userIds.joined(separator: ",")
                }
            }
        }
    }
    
    func changeOwnerOfConversation(id: String, ownerId: String) {
        try? realm?.write {
            if let conversation = realm?.objects(RMConversation.self)
                                           .filter("id == '\(id)'")
                                           .first {
                conversation.ownerId = ownerId
            }
        }
    }
    
    // RMContact
    func getContact(id: String) -> RMContact? {
        return realm?
            .objects(RMContact.self)
            .filter("id == \(id)")
            .first
    }
    
    func getContacts(ids: [String]) -> Results<RMContact>? {
        let _ids = ids.map { Int($0) ?? 0 }
        return realm?
            .objects(RMContact.self)
            .filter("id IN %@", _ids)
    }
    
    // RMMessage
    func saveMessage(_ message: RMMessage) {
        try? realm?.write {
            self.realm?.add(message, update: .modified)
        }
    }
    
    func getUnreadConversationsAndMissedCalls() -> Int {
        guard let currentUser = realm?
            .objects(RMUser.self)
            .first,
            let realm = self.realm
            else {
                return 0
        }

        let currentUserId = String(currentUser.id)
        let unreadConversations = realm
            .objects(RMMessage.self)
            .filter("\(#keyPath(RMMessage.status)) IN %@", ["sent", "received"])
            .filter("\(#keyPath(RMMessage.senderID)) != %@", currentUserId)
            .distinct(by: ["\(#keyPath(RMMessage.dialogID))"])
        let conversations = realm
            .objects(RMConversation.self)
            .filter("\(#keyPath(RMConversation.id)) IN %@", Array(unreadConversations.map { $0.dialogID }))
        let messages = realm
            .objects(RMMessage.self)
            .filter("\(#keyPath(RMMessage.status)) IN %@", ["sent", "received"])
            .filter("\(#keyPath(RMMessage.senderID)) != %@", currentUserId)
            .filter("\(#keyPath(RMMessage.isMissedCall)) == %@", true)
        let missedCallCount = messages.count
        let excludeConversations = messages.distinct(by: ["\(#keyPath(RMMessage.dialogID))"]).count
        return conversations.count + missedCallCount - excludeConversations
    }
    
    func getCurrentUser() -> RMUser? {
        return realm?
            .objects(RMUser.self)
            .first
    }
    
    func saveReceiverMessageTimeToLive(groupId: String, messageTimeToLive: Double) {
        if let draft = realm?.objects(RMDraftConversation.self).filter("groupId == %@", groupId).first {
            try? realm?.write {
                draft.receiverMessageTimeToLive = messageTimeToLive
            }
        } else {
            let draf = RMDraftConversation()
            draf.groupId = groupId
            draf.message = ""
            draf.senderMessageTimeToLive = 0.0
            draf.receiverMessageTimeToLive = messageTimeToLive
            try? realm?.write {
                self.realm?.add(draf, update: .modified)
            }
        }
    }
}
