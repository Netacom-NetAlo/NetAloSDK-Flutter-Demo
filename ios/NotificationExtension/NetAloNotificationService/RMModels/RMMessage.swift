//
//  RMMessage.swift
//  Netalo
//
//  Created by Tran Phong on 1/14/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Realm
import RealmSwift

internal class RMMessage: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var createdAt: Double = 0.0
    @objc dynamic var expiredAt: Double = 0.0
    @objc dynamic var senderID: String = ""
    @objc dynamic var dialogID: String = ""
    @objc dynamic var payload: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var isMissedCall: Bool = false
    @objc dynamic var deletedUins: String = ""
    @objc dynamic var isEncrypted: Bool = false
    @objc dynamic var isDecrypted: Bool = false
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
