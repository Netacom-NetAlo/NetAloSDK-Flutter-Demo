//
//  RMConversation.swift
//  Netalo
//
//  Created by Tran Phong on 1/15/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import RealmSwift

internal class RMConversation: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var payload: String = ""
    @objc dynamic var ownerId: String = ""
    @objc dynamic var userIds: String = ""
    @objc dynamic var userNames: String = ""
    @objc dynamic var lastMesage: RMMessage?
    @objc dynamic var isMuted: Bool = false
    @objc dynamic var isPinned: Bool = false
    @objc dynamic var displayName: String = ""
    @objc dynamic var avatarUrl: String = ""
    @objc dynamic var backgroundUrl: String = ""
    @objc dynamic var isBlur: Bool = false
    let blockedUins = List<String>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
