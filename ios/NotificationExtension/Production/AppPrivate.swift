//
//  AppPrivate.swift
//  PVTicket-app-ios
//
//  Created by Nhu Nguyet on 4/2/19.
//  Copyright © 2019 Nhu Nguyet. All rights reserved.
//

import Foundation

struct AppPrivate {

    public var serverUrl: String
    public var socketUrl: String
    public var trackingUrl: String

    public var imageUrl: String
    public var homeUrl: String
    public var storeUrl: String

    public var appGroupIdentifier: String
    public var databaseIdentifier: String
    public var databaseVersion: UInt64

    public var appConfig: AppConfig
    public var trackingConfig: TrackingConfig
    public var featureConfig: FeatureConfig

    public var messageVersion: Int
    public var isCallProduction: Bool

    public var imageMaxSize: Double = 1080

    // MARK: - Pre-defines enviroments
    static var `default` = testing
    private static let _messageVersion: Int = 1
    private static let _databaseVersion: UInt64 = 23

    static let testing = AppPrivate(
        serverUrl:          "https://dev.api.netalo.vn/api",
        socketUrl:          "https://dev.conn1.netalo.vn",
        trackingUrl:        "http://dev-sdkapi-loggo.phoeniz.com",
        imageUrl:           "https://dev.api.netalo.vn/api/content/blobs/",
        homeUrl:            "http://netalo.vn",
        storeUrl:           "https://apps.apple.com/vn/app/netalo/id1529842070",
        appGroupIdentifier: "group.vn.netacom.netalo-dev",
        databaseIdentifier: "default.realm",
        databaseVersion:    _databaseVersion,
        appConfig:          AppConfig(authKey: "appkey", appID: 1, accountKey: "accountKey"),
        trackingConfig:     TrackingConfig(appID: "5f4caade773e711cf28bd667", appKey: "d74f039a1798d16b2b9f04e1ca5a4c70"),
        featureConfig:      FeatureConfig(user: FeatureConfig.UserConfig(forceUpdateProfile: false)),
        messageVersion:     _messageVersion,
        isCallProduction:   false
    )

    static let production = AppPrivate(
        serverUrl:          "https://api.netalo.vn/api",
        socketUrl:          "https://conn1.netalo.vn",
        trackingUrl:        "http://sdkapi-loggo.phoeniz.com",
        imageUrl:           "https://api.netalo.vn/api/content/blobs/",
        homeUrl:            "https://netalo.vn",
        storeUrl:           "https://apps.apple.com/vn/app/netalo/id1529842070",
        appGroupIdentifier: "group.vn.netacom.netalo-dev",
        databaseIdentifier: "default.realm",
        databaseVersion:    _databaseVersion,
        appConfig:          AppConfig(authKey: "appkey", appID: 1, accountKey: "accountKey"),
        trackingConfig:     TrackingConfig(appID: "5f4caade773e711cf28bd667", appKey: "d74f039a1798d16b2b9f04e1ca5a4c70"),
        featureConfig:      FeatureConfig(user: FeatureConfig.UserConfig(forceUpdateProfile: false)),
        messageVersion:     _messageVersion,
        isCallProduction:   true
    )

    static let dev = AppPrivate(
        serverUrl:          "http://128.199.176.26:9999/api",
        socketUrl:          "http://128.199.176.26:2082",
        trackingUrl:        "http://dev-sdkapi-loggo.phoeniz.com",
        imageUrl:           "http://128.199.176.26:9999/api/content/blobs/",
        homeUrl:            "http://netalo.vn",
        storeUrl:           "https://apps.apple.com/vn/app/netalo/id1529842070",
        appGroupIdentifier: "group.vn.netacom.netalo-dev",
        databaseIdentifier: "default.realm",
        databaseVersion:    _databaseVersion,
        appConfig:          AppConfig(authKey: "appkey", appID: 1, accountKey: "accountKey"),
        trackingConfig:     TrackingConfig(appID: "5f4caade773e711cf28bd667", appKey: "d74f039a1798d16b2b9f04e1ca5a4c70"),
        featureConfig:      FeatureConfig(user: FeatureConfig.UserConfig(forceUpdateProfile: false)),
        messageVersion:     _messageVersion,
        isCallProduction:   false
    )
}

struct AppConfig {
    let authKey: String
    let appID: Int64
    let accountKey: String
}

struct TrackingConfig {
    let appID: String
    let appKey: String
}

public struct FeatureConfig {
    public struct UserConfig {
        public var forceUpdateProfile: Bool
        public init(forceUpdateProfile: Bool) {
            self.forceUpdateProfile = forceUpdateProfile
        }
    }

    public var user: UserConfig

    public init(user: UserConfig) {
        self.user = user
    }
}
