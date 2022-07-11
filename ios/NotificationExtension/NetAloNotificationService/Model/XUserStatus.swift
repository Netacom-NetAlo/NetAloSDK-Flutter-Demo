//
//  XUserStatus.swift
//  NetaloUISDK
//
//  Created by Hung Thai Minh on 8/19/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public enum OnlineStatus: Int {
    case unknown            = 0
    case online             = 1
    case offline            = 2
    case idle               = 3
    case invisible          = 4
    case away               = 5
    case busy               = 6
    case unrecognized       = -1
    
    var stringValue: String {
        switch self {
        case .unknown: return "Unknown"
        case .online: return "Online"
        case .offline: return "Offline"
        case .idle: return "Idle"
        case .invisible: return "Invisible"
        case .away: return "Away"
        case .busy: return "Busy"
        case .unrecognized: return "Unknown"
        }
    }
}

public struct XUserStatus: Codable {
    
    var uin: String
    var messageStatus: String
    var _onlineStatus: Int
    var lastSeenAt: Double
    
    var onlineStatus: OnlineStatus {
        return OnlineStatus(rawValue: _onlineStatus) ?? .offline
    }
    
    enum CodingKeys: String, CodingKey {
        case uin
        case messageStatus = "message_status"
        case _onlineStatus = "online_status"
        case lastSeenAt = "last_seen_at"
    }
    
    init(userStatus: NTUserStatus) {
        self.uin = userStatus.uin
        self.messageStatus = userStatus.messageStatus
        self._onlineStatus = userStatus.onlineStatus
        self.lastSeenAt = userStatus.lastSeenAt
    }
    
    init(userStatus: RMUserStatus) {
        self.uin = userStatus.userID
        self.messageStatus = userStatus.messageStatus
        self._onlineStatus = userStatus.onlineStatus
        self.lastSeenAt = userStatus.lastSeenAt
    }
}
