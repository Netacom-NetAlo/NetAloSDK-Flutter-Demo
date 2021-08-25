//
//  BuildConfig.swift
//  NotificationExtention
//
//  Created by Tran Phong on 2/23/21.
//  Copyright © 2021 'Netalo'. All rights reserved.
//

import Foundation

public struct NetAloBuildConfig {
    var databaseVersion: UInt64
    var imageUrl: String
    var appGroupIdentifier: String
    var databaseIdentifier: String
    
    static var `default` = NetAloBuildConfig(databaseVersion: 23, imageUrl: "https://dev.api.netalo.vn/api/content/blobs/", appGroupIdentifier: "", databaseIdentifier: "default.realm")
    static let dev = NetAloBuildConfig(databaseVersion: 23, imageUrl: "https://dev.api.netalo.vn/api/content/blobs/", appGroupIdentifier: "", databaseIdentifier: "default.realm")
    static let prod = NetAloBuildConfig(databaseVersion: 23, imageUrl: "https://api.netalo.vn/api/content/blobs/", appGroupIdentifier: "", databaseIdentifier: "default.realm")
}
