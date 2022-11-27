//
//  BuildConfig.swift
//  Runner
//
//  Created by Hieu Bui Van  on 22/12/2021.
//

import NetAloLite
import NetAloFull

struct BuildConfig {
    static var config = NetaloConfiguration(
        enviroment: .development,
        appId: 1,
        appKey: "appkey",
        accountKey: "admintestkey",
        appGroupIdentifier: "group.hura.asia-dev",
        storeUrl: URL(string:"https://apps.apple.com/vn/app/hura-hd-video-call/id1630020464")!,
        deeplinkSchema: "hura",
        analytics: [],
        featureConfig: FeatureConfig(
            user: FeatureConfig.UserConfig(
                forceUpdateProfile: false,
                allowCustomUsername: false,
                allowCustomProfile: true,
                allowCustomAlert: false,
                allowAddContact: true,
                allowBlockContact: true,
                allowSetUserProfileUrl: false,
                allowEnableLocationFeature: false,
                allowTrackingUsingSDK: true,
                isHiddenEditProfile: true,
                allowAddNewContact: true
            ),
            chat: FeatureConfig.ChatConfig(
                isVideoCallEnable: true,
                isVoiceCallEnable: true,
                isHiddenSecretChat: true
            ),
            isSyncDataInApp: true,
            allowReferralCode: false,
            searchByLike: true,
            allowReplaceCountrycode: false,
            isSyncContactInApp: true
        ),
        permissions: [SDKPermissionSet.microPhone]
    )
}

