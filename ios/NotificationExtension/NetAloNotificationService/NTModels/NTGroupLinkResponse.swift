//
//  NTGroupLinkResponse.swift
//  NetaloSDK
//
//  Created by Nguyên Duy on 11/12/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

struct NTGroupLinkResponse: Codable {
    let result: Int
    let link: String
    
    enum CodingKeys: String, CodingKey {
        case result, link
    }
    
    func codeCheck() -> Bool {
        return result == 0
    }
}

struct NTListGroupLinkResponse: Codable {
    let result: Int
    let links: [String]
    
    enum CodingKeys: String, CodingKey {
        case result, links
    }
    
    func codeCheck() -> Bool {
        return result == 0
    }
}
