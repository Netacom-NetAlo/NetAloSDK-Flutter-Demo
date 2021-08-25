//
//  NTStartCall.swift
//  NetaloSDK
//
//  Created by Nhu Nguyet on 11/3/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct NTStartCall: Codable {
    
    public static let EVENT_CALL_TYPE = 2
    
    public let groupID: String
    public let callID: String
    public let event: Int
    
    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case callID = "call_id"
        case event = "event"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        groupID = values.decodex(key: .groupID, defaultValue: "")
        callID = values.decodex(key: .callID, defaultValue: "")
        event = values.decodex(key: .event, defaultValue: 0)
    }
    
    public init(groupID: String, callID: String, event: Int) {
        self.groupID = groupID
        self.callID = callID
        self.event = event
    }
}
