//
//  IMStopCall.swift
//  NetaloSDK
//
//  Created by Tran Phong on 6/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct NTStopCall: Codable {
    public let callId: String
    public let uin: String
    
    enum CodingKeys: String, CodingKey {
        case callId = "call_id"
        case uin = "uin"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        callId = values.decodex(key: .callId, defaultValue: "")
        uin = values.decodex(key: .uin, defaultValue: "")
    }
    
    public init(callId: String, uin: String) {
        self.callId = callId
        self.uin = uin
    }
}
