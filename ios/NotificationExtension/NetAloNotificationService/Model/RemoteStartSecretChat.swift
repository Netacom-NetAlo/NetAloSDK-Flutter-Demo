//
//  StartSecretChat.swift
//  Netalo
//
//  Created by Tran Phong on 10/9/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

struct RemoteStartSecretChat: Codable {
    let groupID, uin, deviceID, identityKey: String
    let baseKey, oneTimePreKey: String

    enum CodingKeys: String, CodingKey {
        case groupID = "groupId"
        case uin
        case deviceID = "deviceId"
        case identityKey, baseKey, oneTimePreKey
    }
}

struct RemoteDeleteSecretChat: Codable {
    let groupID: String

    enum CodingKeys: String, CodingKey {
        case groupID = "groupId"
    }
}


extension RemoteStartSecretChat {
    func toDictionary() -> [String: Any] {
        return [
            "group_id": groupID,
            "uin": uin,
            "device_id": deviceID,
            "identity_key": identityKey,
            "base_key": baseKey,
            "one_time_pre_key": oneTimePreKey
        ]
    }
}
