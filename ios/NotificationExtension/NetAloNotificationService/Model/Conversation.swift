//
//  Conversation.swift
//  NotificationExtention
//
//  Created by Tran Phong on 7/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    func decodex<T>(key: K, defaultValue: T) -> T
        where T : Decodable {
            return (try? decode(T.self, forKey: key)) ?? defaultValue
    }
}

struct Conversation: Codable {
    let type: Int
    let groupID, name: String
    var ownerUin: String
    var occupantsUins: [String]
    var avatarUrl: String = ""
    var isGroupChat: Bool {
        return type == 2
    }
    
    var occupantUsers: [Contact] {
        didSet {
            // Move group owner up
            occupantsUins = occupantsUins.sorted(by: { $0 <= $1 && $0 == ownerUin })
        }
    }
    
    var userNames: [String: String] {
        return occupantUsers.reduce([String: String](), { acc, val in
            var dict = acc
            dict[String(val.id)] = val.fullName
            return dict
        })
    }
    
    public func displayNameForSender(_ senderId: String) -> String {
        if isGroupChat {
            let userIds = occupantsUins.joined(separator: ", ")
            guard occupantUsers.count > 0 else {
                return name != "" ? name : userIds
            }

            return name != "" ? name : occupantUsers.compactMap({ $0.fullName }).joined(separator: ", ")
        } else {
            let recipientID = occupantsUins.first(where: { $0 != senderId }) ?? occupantsUins.joined(separator: ", ")
            guard occupantUsers.count > 0, let recipient = occupantUsers.first(where: { String($0.id) == recipientID }) else {
                return recipientID
            }
            return recipient.fullName
        }
    }
    
    public mutating func setOccupantUsers(_ users:  [Contact]) {
        self.occupantUsers = users
    }
    
    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case type, name
        case occupantsUins = "occupants_uins"
        case ownerUin = "owner_uin"
        case avatarUrl = "avatar_url"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        groupID = values.decodex(key: .groupID, defaultValue: "")
        name = values.decodex(key: .name, defaultValue: "")
        avatarUrl = values.decodex(key: .avatarUrl, defaultValue: "")
        type = values.decodex(key: .type, defaultValue: 0)
        occupantsUins = values.decodex(key: .occupantsUins, defaultValue: [])
        ownerUin = values.decodex(key: .ownerUin, defaultValue: "")
        occupantUsers = []
    }
}

extension Conversation {
    init?(conversation: RMConversation) {
        let decoder = JSONDecoder()
        if let conv = try? decoder.decode(Conversation.self, from: conversation.payload.data(using: .utf8) ?? Data())  {
            self = conv
            self.avatarUrl = conversation.avatarUrl
            self.ownerUin = conversation.ownerId
        } else {
            return nil
        }
    }
}
