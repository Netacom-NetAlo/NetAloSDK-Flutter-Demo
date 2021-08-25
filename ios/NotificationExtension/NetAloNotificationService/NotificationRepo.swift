//
//  NotificationRepo.swift
//  NotificationExtention
//
//  Created by Tran Phong on 7/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

protocol NotificationRepo {
    func getConversationInfo(id: String) -> Conversation?
    func updateConversationName(id: String, conversationName: String)
    func updateConversationBackground(id: String, background: QBGroupBackground)
    func updateConversationAvatarUrl(id: String, avatarUrl: String)
    func addMembersToConversation(id: String, memberIds: [String])
    func removeMemberInConversation(id: String, memberId: String)
    func changeOwnerOfConversation(id: String, ownerId: String)
    func getContactInfo(id: String) -> Contact?
    func saveMessage(_ message: QBMessage)
    func getContactsInfo(ids: [String]) -> [Contact]
    func getUnreadConversationsAndMissedCalls() -> Int
    func removeConversation(id: String)
    func getCurrentUserId() -> Int64?
    func saveReceiverMessageTimeToLive(groupId: String, messageTimeToLive: Double)
}


class NotificationRepoImpl: NotificationRepo {
    private let localService: LocalRepo = LocalRepoImpl()
    
    func getConversationInfo(id: String) -> Conversation? {
        if let conv = localService.getConversation(id: id) {
            if var conversation = Conversation(conversation: conv) {
                let occupantUsers = self.getContactsInfo(ids: conversation.occupantsUins)
                conversation.setOccupantUsers(occupantUsers)
                return conversation
            }
        }
        return nil
    }
    
    func removeConversation(id: String) {
        localService.removeConversation(id: id)
    }
    
    func updateConversationName(id: String, conversationName: String) {
        localService.updateConversationName(id: id, conversationName: conversationName)
    }
    
    func updateConversationBackground(id: String, background: QBGroupBackground) {
        localService.updateConversationBackground(id: id, background: background)
    }
    
    func updateConversationAvatarUrl(id: String, avatarUrl: String) {
        localService.updateConversationAvatarUrl(id: id, avatarUrl: avatarUrl)
    }
    
    func addMembersToConversation(id: String, memberIds: [String]) {
        if let conversation = self.getConversationInfo(id: id) {
            var membersIdSet = Set(conversation.occupantsUins)
            for memberId in memberIds {
                membersIdSet.insert(memberId)
            }
            localService.updateMembersToConversation(id: id, memberIds: Array(membersIdSet))
        }
    }
    
    func removeMemberInConversation(id: String, memberId: String) {
        localService.removeMemberInConversation(id: id, memberId: memberId)
    }
    
    func changeOwnerOfConversation(id: String, ownerId: String) {
        localService.changeOwnerOfConversation(id: id, ownerId: ownerId)
    }
    
    func getContactInfo(id: String) -> Contact? {
        if let contact = localService.getContact(id: id) {
            return Contact(contact: contact)
        }
        return nil
    }
    
    func getContactsInfo(ids: [String]) -> [Contact] {
        if let localContact = localService.getContacts(ids: ids) {
            return localContact.compactMap { Contact(contact: $0) }
        }
        return []
    }
    
    func saveMessage(_ message: QBMessage) {
        localService.saveMessage(RMMessage(qbMessage: message))
    }
    
    func getUnreadConversationsAndMissedCalls() -> Int {
        return localService.getUnreadConversationsAndMissedCalls()
    }
    
    func getCurrentUserId() -> Int64? {
        return localService.getCurrentUser()?.id
    }
    
    func saveReceiverMessageTimeToLive(groupId: String, messageTimeToLive: Double) {
        localService.saveReceiverMessageTimeToLive(groupId: groupId, messageTimeToLive: messageTimeToLive)
    }
}
