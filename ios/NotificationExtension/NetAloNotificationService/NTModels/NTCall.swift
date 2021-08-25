//
//  IMCall.swift
//  NetaloSDK
//
//  Created by Tran Phong on 6/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

struct NTCallResponse: Codable {
    let call: NTCall
}

public struct NTCall: Codable {
    public static let CALL_TYPE_UNKNOWN = 0
    public static let CALL_TYPE_PRIVATE = 1
    public static let CALL_TYPE_GROUP = 2

    public static let MEIDA_TYPE_UNKNOWN = 0
    public static let MEDIA_TYPE_AUDIO = 1
    public static let MEDIA_TYPE_VIDEO = 2

    public static let CALL_STATUS_UNKNOWN = 0
    public static let CALL_STATUS_ONGOING = 1
    public static let CALL_STATUS_TIMEOUT = 2
    public static let CALL_STATUS_FAILED = 3
    
    public let id: String
    public let groupID: String
    public let mediaType: Int
    public let callStatus: Int
    public let type: Int
    public let callerUin: String
    public let calleeUins: [String]
    public let acceptedUins: [String]
    public let startedAt: String
    public let stoppedAt: String
    public let answeredAt: String
    public let connectedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "call_id"
        case groupID = "group_id"
        case type = "call_type"
        case mediaType = "media_type"
        case callStatus = "call_status"
        case callerUin = "caller_uin"
        case calleeUins = "callee_uins"
        case acceptedUins = "accepted_uins"
        case startedAt = "started_at"
        case stoppedAt = "stopped_at"
        case answeredAt = "accepted_at"
        case connectedAt = "connected_at"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodex(key: .id, defaultValue: "")
        groupID = values.decodex(key: .groupID, defaultValue: "")
        mediaType = values.decodex(key: .mediaType, defaultValue: 0)
        callStatus = values.decodex(key: .callStatus, defaultValue: 0)
        type = values.decodex(key: .type, defaultValue: 0)
        callerUin = values.decodex(key: .callerUin, defaultValue: "")
        calleeUins = values.decodex(key: .calleeUins, defaultValue: [])
        acceptedUins = values.decodex(key: .acceptedUins, defaultValue: [])
        startedAt = values.decodex(key: .startedAt, defaultValue: "0")
        stoppedAt = values.decodex(key: .stoppedAt, defaultValue: "0")
        answeredAt = values.decodex(key: .answeredAt, defaultValue: "0")
        connectedAt = values.decodex(key: .connectedAt, defaultValue: "0")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(groupID, forKey: .groupID)
        try container.encode(mediaType, forKey: .mediaType)
        try container.encode(callerUin, forKey: .callerUin)
        try container.encode(calleeUins, forKey: .calleeUins)
        if id != "" {
            try container.encode(callStatus, forKey: .callStatus)
            try container.encode(startedAt, forKey: .startedAt)
            try container.encode(stoppedAt, forKey: .stoppedAt)
            try container.encode(acceptedUins, forKey: .acceptedUins)
            try container.encode(answeredAt, forKey: .answeredAt)
            try container.encode(connectedAt, forKey: .connectedAt)
        }
    }
    
    
    
    public init(id: String = "", mediaType: Int, groupID: String, callerUin: String, calleeUins: [String]) {
        self.id = id
        self.groupID = groupID
        self.mediaType = mediaType
        self.callStatus = 0
        self.type = 1
        self.callerUin = callerUin
        self.calleeUins = calleeUins
        self.acceptedUins = []
        self.startedAt = "0"
        self.stoppedAt = "0"
        self.answeredAt = "0"
        self.connectedAt = "0"
    }
    
    public init?(userInfo: [AnyHashable : Any]) {
        guard
            let type = userInfo["Type"] as? String, type == "call",
            let _payload = (userInfo["Payload"] as? String)?.data(using: .utf8),
            let payload = (try? JSONSerialization.jsonObject(with: _payload, options: .allowFragments)) as? [AnyHashable : Any],
            let call = payload["call"] as? [AnyHashable : Any]
            else
        { return nil }
        
        guard
            let callId = call["callId"] as? String,
            let groupId = call["groupId"] as? String,
            let mediaType = call["mediaType"] as? String,
            let callerUin = call["callerUin"] as? String,
            let calleeUins = call["calleeUins"] as? [String]
            else
        { return nil }
        
        let _mediaType = [
            "MEDIA_TYPE_VIDEO": NTCall.MEDIA_TYPE_VIDEO,
            "MEDIA_TYPE_AUDIO": NTCall.MEDIA_TYPE_AUDIO
        ][mediaType] ?? NTCall.MEIDA_TYPE_UNKNOWN
        
        self.init(id: callId, mediaType: _mediaType, groupID: groupId, callerUin: callerUin, calleeUins: calleeUins)
    }
}
