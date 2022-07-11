package com.netacom.flutter_sdk

import android.content.Context
import androidx.work.Configuration
import com.asia.sdkui.ui.sdk.NetAloSDK
import com.asia.sdkui.ui.sdk.NetAloSdkCore
import com.asia.sdkcore.entity.ui.theme.NeTheme
import com.asia.sdkcore.sdk.AccountKey
import com.asia.sdkcore.sdk.AppID
import com.asia.sdkcore.sdk.AppKey
import com.asia.sdkcore.sdk.SdkConfig
import com.netacom.flutter_sdk.MainActivity
import dagger.hilt.android.HiltAndroidApp
import io.flutter.app.FlutterApplication
import io.realm.Realm
import kotlinx.coroutines.ObsoleteCoroutinesApi
import javax.inject.Inject

@ObsoleteCoroutinesApi
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