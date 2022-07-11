//
//  RMUser.swift
//  NetaloUISDK
//
//  Created by Tran Phong on 8/28/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import RealmSwift

internal class RMUser: Object {
    @objc dynamic var id: Int64 = 0
    @objc dynamic var token: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var avatar: String = ""
    @objc dynamic var payload: String = ""
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
