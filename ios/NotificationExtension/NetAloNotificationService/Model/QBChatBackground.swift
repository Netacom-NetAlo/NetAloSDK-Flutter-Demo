//
//  QBChatBackground.swift
//  NetaloUISDK
//
//  Created by Nguyên Duy on 08/03/2021.
//  Copyright © 2021 'Netalo'. All rights reserved.
//

import Foundation

public struct QBGroupBackground: Codable, Equatable {
    public var backgroundUrl: String
    public var isBlur: Bool
    
    enum CodingKeys: String, CodingKey {
        case isBlur = "is_blur"
        case backgroundUrl = "background_url"
    }
    
    public func toString() -> String {
        let encoder = JSONEncoder()
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
    
    public static func == (lhs: QBGroupBackground, rhs: QBGroupBackground) -> Bool {
        return lhs.backgroundUrl == rhs.backgroundUrl && lhs.isBlur == rhs.isBlur
    }
}
