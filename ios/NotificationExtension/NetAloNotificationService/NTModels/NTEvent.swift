//
//  IMEvent.swift
//  NetaloSDK
//
//  Created by Tran Phong on 6/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct NTEvent: Codable {
    public static let EVENT_TYPE_UNKNOWN = 0
    public static let EVENT_TYPE_CALL_CANCEL = 1
    public static let EVENT_TYPE_CALL_AVAILABLE = 2
    public static let EVENT_TYPE_CALL_BUSY = 3
    public static let EVENT_TYPE_CALL_RECEIVED_EVENT = 4
    public static let EVENT_TYPE_CALL_REQUEST_VIDEO = 5
    public static let EVENT_TYPE_CALL_INACTIVE_VIDEO = 6
    public static let EVENT_TYPE_CALL_ACTIVE_VIDEO = 7
    public static let EVENT_TYPE_CALL_CHECKING_AVAILABLE = 8
    public static let EVENT_TYPE_MESSAGING_START_TYPING = 9
    public static let EVENT_TYPE_MESSAGING_STOP_TYPING = 10
    public static let EVENT_TYPE_CALL_CONNECTING = 11
    
    public let senderUin: String
    public let receiverUin: String
    public let type: Int
    public let data: String
    public let groupId: String
    public let callId: String
    
    enum CodingKeys: String, CodingKey {
        case senderUin = "sender_uin"
        case receiverUin = "receiver_uin"
        case type = "type"
        case data = "data"
        case groupId = "group_id"
        case callId = "call_id"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        senderUin = values.decodex(key: .senderUin, defaultValue: "")
        receiverUin = values.decodex(key: .receiverUin, defaultValue: "")
        type = values.decodex(key: .type, defaultValue: 0)
        data = values.decodex(key: .data, defaultValue: "")
        groupId = values.decodex(key: .groupId, defaultValue: "")
        callId = values.decodex(key: .callId, defaultValue: "")
    }
    
    public init(senderUin: String, receiverUin: String, type: Int, data: String, groupId: String, callId: String) {
        self.senderUin = senderUin
        self.receiverUin = receiverUin
        self.type = type
        self.data = data
        self.groupId = groupId
        self.callId = callId
    }
}
