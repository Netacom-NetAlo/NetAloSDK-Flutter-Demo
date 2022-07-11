//
//  NTBlockContactList.swift
//  NetaloSDK
//
//  Created by Hung Thai Minh on 24/11/2020.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct NTBlockContactList: Codable {
    public let result: Int
    public var list: [NTBlockContact] = []
    
    public func codeCheck() -> Bool {
        return result == 0
    }
}

public struct NTBlockContact: Codable {
    public let uin: String
    public let group_id: String
}
