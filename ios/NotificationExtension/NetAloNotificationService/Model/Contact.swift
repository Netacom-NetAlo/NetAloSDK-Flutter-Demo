//
//  Contact.swift
//  NotificationExtention
//
//  Created by Tran Phong on 7/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct Contact: Codable {
    var id: Int64
    var phone: String
    var fullName: String
    var email: String
    var profileUrl: String
    
    enum CodingKeys: String, CodingKey {
           case fullName = "full_name"
           case id = "Id"
           case phone, email
           case profileUrl = "profile_url"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodex(key: .id, defaultValue: 0)
        phone = values.decodex(key: .phone, defaultValue: "")
        fullName = values.decodex(key: .fullName, defaultValue: "")
        email = values.decodex(key: .email, defaultValue: "")
        profileUrl = values.decodex(key: .profileUrl, defaultValue: "")
    }
}

extension Contact {
    init(contact: RMContact) {
        self.id = contact.id.value ?? 0
        self.phone = contact.phone ?? ""
        self.fullName = contact.localContact?.name ?? contact.fullName ?? contact.phone ?? ""
        self.email = contact.email ?? ""
        self.profileUrl = contact.profileUrl ?? ""
    }
}
