//
//  NTSecretChat.swift
//  NetaloSDK
//
//  Created by Tran Phong on 10/7/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

// TODO: Refactor keys + parse default values

public struct NTSecretChat: Codable {
    public let uin: String
    public let device_id: String
    public let identity_key: String
    public let base_key: String
    public let one_time_pre_key: String
}

public struct NTStartSecretChat: Codable {
    public let group_id: String
    public let uin: String
    public let device_id: String
    public let identity_key: String
    public let base_key: String
    public let one_time_pre_key: String
}

public struct NTAcceptSecretChat: Codable {
    public let group_id: String
    public let uin: String
    public let device_id: String
    public let identity_key: String
    public let base_key: String
    public let one_time_pre_key: String
}

public struct NTDeleteSecretChat: Codable {
    public let group_id: String
    public let group_name: String
    public let group_avatar: String
}

public struct NTSecretChatResponse: Codable {
    public let result: Int
    public let group: NTConversation
    
    func codeCheck() -> Bool {
        return result == 0
    }
}
