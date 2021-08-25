//
//  RMUserStatus.swift
//  NetaloUISDK
//
//  Created by Nguyên Duy on 10/12/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Realm
import RealmSwift

internal class RMUserStatus: Object {
    @objc dynamic var userID: String = ""
    @objc dynamic var messageStatus: String = ""
    @objc dynamic var onlineStatus: Int = 0
    @objc dynamic var lastSeenAt: Double = 0.0
    
    override public static func primaryKey() -> String? {
        return "userID"
    }
    
    convenience init(userStatus: XUserStatus) {
        self.init()
        self.userID = userStatus.uin
        self.messageStatus = userStatus.messageStatus
        self.onlineStatus = userStatus._onlineStatus
        self.lastSeenAt = userStatus.lastSeenAt
    }
}
