//
//  IMIceCandidate.swift
//  NetaloSDK
//
//  Created by Tran Phong on 6/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct NTIceCandidate: Codable {
    public let candidate: String
    public let sdpMid: String
    public let sdpMlineIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case candidate = "candidate"
        case sdpMid = "sdp_mid"
        case sdpMlineIndex = "sdp_mline_index"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        candidate = values.decodex(key: .candidate, defaultValue: "")
        sdpMid = values.decodex(key: .sdpMid, defaultValue: "")
        sdpMlineIndex = values.decodex(key: .sdpMlineIndex, defaultValue: 0)
    }
    
    public init(candidate: String, sdpMid: String, sdpMlineIndex: Int) {
        self.candidate = candidate
        self.sdpMid = sdpMid
        self.sdpMlineIndex = sdpMlineIndex
    }
}
