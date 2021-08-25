//
//  IMUserStatus.swift
//  NetaloSDK
//
//  Created by Nguyên Duy on 6/23/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

// MARK: - IMUserStatus
public struct NTUserStatusResponse: Codable {
    public let userStatus: NTUserStatus
    enum CodingKeys: String, CodingKey {
        case userStatus = "user_status"
    }
}

public struct NTUserStatus: Codable {
    public let uin: String
    public let onlineStatus: Int
    public let messageStatus: String
    public let lastSeenAt: Double
    public var status: NTDefines.OnlineStatus {
        return NTDefines.OnlineStatus(rawValue: onlineStatus) ?? .offline
    }

    enum CodingKeys: String, CodingKey {
        case uin
        case onlineStatus = "online_status"
        case messageStatus = "message_status"
        case lastSeenAt = "last_seen_at"
    }
}
