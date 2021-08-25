//
//  NTChatBackground.swift
//  NetaloSDK
//
//  Created by Nguyên Duy on 08/03/2021.
//  Copyright © 2021 'Netalo'. All rights reserved.
//

import Foundation

public struct NTGroupBackground: Codable {
    public var backgroundUrl: String
    public var isBlur: Bool
    
    enum CodingKeys: String, CodingKey {
        case backgroundUrl = "background_url"
        case isBlur = "is_blur"
    }
    
    public func toString() -> String {
        let encoder = JSONEncoder()
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
}
