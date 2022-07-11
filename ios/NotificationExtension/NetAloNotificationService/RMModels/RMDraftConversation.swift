//
//  RMDraftConversation.swift
//  Netalo
//
//  Created by Tran Phong on 7/9/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import RealmSwift

internal class RMDraftConversation: Object {
    @objc dynamic var groupId: String = ""
    @objc dynamic var message: String = ""
    @objc dynamic var receiverMessageTimeToLive: Double = 0.0
    @objc dynamic var senderMessageTimeToLive: Double = 0.0
    
    override public static func primaryKey() -> String? {
        return "groupId"
    }
}
