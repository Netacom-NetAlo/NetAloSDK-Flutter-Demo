//
//  IMIceSdp.swift
//  NetaloSDK
//
//  Created by Tran Phong on 6/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct NTIceSdp: Codable {
    public static let SDP_TYPE_UNKNOWN = 0
    public static let SDP_TYPE_OFFER = 1
    public static let SDP_TYPE_ANSWER = 2
    
    public let sdp: String
    public let type: Int
    
    enum CodingKeys: String, CodingKey {
        case sdp = "sdp"
        case type = "type"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sdp = values.decodex(key: .sdp, defaultValue: "")
        type = values.decodex(key: .type, defaultValue: 0)
    }
    
    public init(sdp: String, type: Int) {
        self.sdp = sdp
        self.type = type
    }
}
