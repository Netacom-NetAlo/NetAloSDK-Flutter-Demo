//
//  IMAnswerCall.swift
//  NetaloSDK
//
//  Created by Tran Phong on 6/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation
    
public struct NTAnswerCall: Codable {
    public static let ANSWER_CALL_UNKNOWN = 0
    public static let ANSWER_CALL_ACCEPT = 1
    public static let ANSWER_CALL_REJECT = 2
    public static let ANSWER_CALL_TIMEOUT = 3
    public static let ANSWER_CALL_FAILED = 4
    
    public let id: String
    public let calleeUin: String
    public let type: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "call_id"
        case calleeUin = "callee_uin"
        case type = "answer"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodex(key: .id, defaultValue: "")
        calleeUin = values.decodex(key: .calleeUin, defaultValue: "")
        type = values.decodex(key: .type, defaultValue: 0)
    }
    
    public init(id: String, calleeUin: String, type: Int) {
        self.id = id
        self.calleeUin = calleeUin
        self.type = type
    }
}
