package com.netacom.flutter_sdk

import android.content.Context
import androidx.work.Configuration
import com.netacom.full.ui.sdk.NetAloSDK
import com.netacom.full.ui.sdk.NetAloSdkCore
import com.netacom.lite.entity.ui.theme.NeTheme
import com.netacom.lite.sdk.AccountKey
import com.netacom.lite.sdk.AppID
import com.netacom.lite.sdk.AppKey
import com.netacom.lite.sdk.SdkConfig
import dagger.hilt.android.HiltAndroidApp
import io.flutter.app.FlutterApplication
import io.realm.Realm
import javax.inject.Inject

@HiltAndroidApp
class MyApplication : FlutterApplication(), Configuration.Provider {

    @Inject
    lateinit var netAloSdkCore: NetAloSdkCore

    override fun getWorkManagerConfiguration() =
        Configuration.Builder()
            .setWorkerFactory(netAloSdkCore.workerFactory)
            .build()

    private val sdkConfig = SdkConfig(
        appId = AppID.NETALO_DEV,
        appKey = AppKey.NETALO_DEV,
        accountKey = AccountKey.NETALO_DEV,
        isSyncContact = false,
        hidePhone = true,
        hideCreateGroup = true,
        hideAddInfoInChat = true,
        hideInfoInChat = true,
        hideCallInChat = true,
        classMainActivity = MainActivity::class.java.name
    )

    private val sdkTheme = NeTheme(
        mainColor = "#9c5aff",
        subColorLight = "#9c5aff",
        subColorDark = "#9c5aff",
        toolbarDrawable = "#9c5aff"
    )

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        Realm.init(this)
    }

    override fun onCreate() {
        super.onCreate()
        NetAloSDK.initNetAloSDK(
            context = this,
            netAloSdkCore = netAloSdkCore,
            sdkConfig = sdkConfig,
            neTheme = sdkTheme
        )
    }
}