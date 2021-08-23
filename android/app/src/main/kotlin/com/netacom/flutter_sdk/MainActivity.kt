package com.netacom.flutter_sdk

import android.os.Bundle
import androidx.annotation.NonNull
import com.netacom.base.chat.logger.Logger
import com.netacom.full.ui.sdk.NetAloSDK
import com.netacom.lite.config.EndPoint
import com.netacom.lite.define.ErrorCodeDefine
import com.netacom.lite.define.GalleryType
import com.netacom.lite.define.NavigationDef
import com.netacom.lite.define.SdkCodeDefine
import com.netacom.lite.entity.ui.local.LocalFileModel
import com.netacom.lite.entity.ui.user.NeUser
import com.netacom.lite.network.model.response.SettingResponse
import com.netacom.lite.sdk.SdkClickNotification
import com.netacom.lite.sdk.SdkCustomChatReceive
import com.netacom.lite.sdk.SdkCustomChatSend
import com.netacom.lite.sdk.SdkStringSend
import com.netacom.lite.util.CallbackResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.collect
import vn.netacom.lomo.callback.OnCheckFriendListener
import java.util.concurrent.TimeUnit
import kotlin.coroutines.CoroutineContext

@FlowPreview
@ExperimentalCoroutinesApi
class MainActivity : FlutterActivity(), CoroutineScope {
    override val coroutineContext: CoroutineContext
        get() = Dispatchers.Main

    private var currentResult: MethodChannel.Result? = null
    var netAloSDKEnvironment = "" // dev,pro

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //Click notification open chat
        intent.extras?.getParcelable<NeUser>(NavigationDef.ARGUMENT_NEUSER)?.apply {
            val neUser = this
            Logger.e("MainActivity:neUser===$this")

            CoroutineScope(Dispatchers.IO).launch {
                delay(TimeUnit.SECONDS.toMillis(1))
                NetAloSDK.openNetAloSDK(
                    this@MainActivity,
                    false,
                    null,
                    NeUser(
                        id = neUser.id,
                        token = neUser.token ?: "",
                        username = neUser.username ?: ""
                    )
                )
            }
        }

        NetAloSDK.checkGroupExist(0) { isExist ->
            Logger.e("isExist==$isExist")
        }
        launch {
            try {
                NetAloSDK.netAloEvent?.receive<ArrayList<LocalFileModel>>()?.collect { listPhoto ->
                    Logger.e("SELECT_PHOTO_VIDEO==$listPhoto")
                    val photoPaths = listPhoto.map { it.filePath }
                    currentResult?.success(photoPaths)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        launch {
            try {
                NetAloSDK.netAloEvent?.receive<SdkStringSend>()?.collect { data ->
                    Logger.e("String:data==${data.data}")
                    PlatformChannel.instance.sendEventHandleLinkFromNetAlo(data.data)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        launch {
            try {
                NetAloSDK.netAloEvent?.receive<LocalFileModel>()?.collect { document ->
                    Logger.e("SELECT_FILE==$document")
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        launch {
            try {
                NetAloSDK.netAloEvent?.receive<SdkCustomChatReceive>()?.collect { sdkCustomChat ->
                    Logger.e("sdkCustomChat11111==$sdkCustomChat")
                    // user for test
                    //id -> {Long@16613} 562949953692027  not friend
                    //id -> {Long@16783} 562949954465668 friend
                    withContext(Dispatchers.Main) {
                        PlatformChannel.instance.sendEventCheckIsFriend(
                            sdkCustomChat.partnerId,
                            object : OnCheckFriendListener {
                                override fun onChecked(isFriend: Boolean) {
                                    Logger.e("checkFriend: $isFriend")
                                    if (isFriend && sdkCustomChat.hideCall) {
                                        NetAloSDK.netAloEvent?.send(SdkCustomChatSend(hideCall = false))
                                    }
                                }
                            }
                        )
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        launch {
            try {
                NetAloSDK.netAloEvent?.receive<SdkClickNotification>()?.collect { sdkClickNoti ->
                    Logger.e("SdkClickNotification==$sdkClickNoti")
                    withContext(Dispatchers.Main) {

                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        //Event SDK
        launch {
            try {
                NetAloSDK.netAloEvent?.receive<Int>()?.collect { errorEvent ->
                    Logger.e("Event:==$errorEvent")
                    when (errorEvent) {
                        ErrorCodeDefine.ERRORCODE_FAILED_VALUE -> {
                            Logger.e("Event:Socket error")
                        }
                        ErrorCodeDefine.ERRORCODE_EXPIRED_VALUE -> {
                            Logger.e("Event:Session expired")
                            runOnUiThread { PlatformChannel.instance.sendEventNetAloSessionExpire() }
                        }
                        SdkCodeDefine.SDK_LOGOUT -> {
                            Logger.e("SdkCodeDefine:SDK_LOGOUT")
                        }
                        SdkCodeDefine.SDK_EXIT -> {
                            Logger.e("SdkCodeDefine:Login SDK_EXIT")
                        }
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        PlatformChannel.instance.init(flutterEngine.dartExecutor.binaryMessenger)
        PlatformChannel.instance.receiveChannel.setMethodCallHandler { call, result ->
            currentResult = result
            when (call.method) {
                "openChatConversation" -> openChatConversation(call, result)
                "getNameTest" -> result.success("heheChannel")
                "openChatWithUser" -> openChatWithUser(call, result)
                "setEnvironmentNetAloSdk" -> {
                    netAloSDKEnvironment = call.arguments as String
                    result.success(true)
                }
                "logOut" -> NetAloSDK.logOut()
                "setNetaloUser" -> setNetaloUser(call, result)
                "pickImages" -> openImagePicker(call, result)
                "blockUser" -> blockUser(call, result, isBlock = true)
                "unBlockUser" -> blockUser(call, result, isBlock = false)
                "checkPermissionCall" -> {
                }
                "setDomainLoadAvatarNetAloSdk" -> setDomainLoadAvatarNetAloSdk(call, result)
                "sendMessage" -> sendMessage(call, result)
                "closeNetAloChat" -> closeNetAloChat()
            }
        }
    }

    private fun sendMessage(call: MethodCall, result: MethodChannel.Result) {
        try {
            val receiver: HashMap<String, Any> = call.argument("receiver")!!
            val message: String = call.argument("message") as? String ?: ""
            NetAloSDK.sendMessage(
                text = message,
                partnerUid = receiver["id"] as? Long ?: 0,
                callbackSuccess = { neSubMessages, tempMessageId, neMessage ->
                    try {
                        Logger.e("onSendMessage = $neMessage neSubMessages=$neSubMessages tempMessageId$tempMessageId")
                        runBlocking(Dispatchers.Main) {
                            currentResult?.success(true)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                },
                callbackError = { error, tempMessageId ->
                    try {
                        Logger.e("onSendMessage:callbackError = $error")
                        runBlocking(Dispatchers.Main) {
                            currentResult?.success(false)
                        }
                    } catch (e: Exception) {
                    }
                }
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun openImagePicker(call: MethodCall, result: MethodChannel.Result) {
        val type = when (call.argument("type") as? Int ?: 1) {
            0 -> GalleryType.GALLERY_ALL
            1 -> GalleryType.GALLERY_PHOTO
            2 -> GalleryType.GALLERY_VIDEO
            else -> GalleryType.GALLERY_ALL
        }
        NetAloSDK.openGallery(
            context = this,
            maxSelections = call.argument("maxImages") as? Int ?: 1,
            autoDismissOnMaxSelections = call.argument("autoDismissOnMaxSelections") ?: true,
            galleryType = type
        )
    }

    private fun blockUser(call: MethodCall, result: MethodChannel.Result, isBlock: Boolean) {
        NetAloSDK.blockUser(
            userId = call.arguments as? Long ?: 0,
            isBlock = isBlock,
            callbackResult = object : CallbackResult<Boolean> {
                override fun callBackError(error: String?) {
                    Logger.e("blockUserError: $error")
                    result.success(false)
                }

                override fun callBackSuccess(isSuccess: Boolean) {
                    Logger.e("blockUserSuccess: $isSuccess")
                    result.success(isSuccess)
                }
            }
        )
    }

    private fun setDomainLoadAvatarNetAloSdk(call: MethodCall, result: MethodChannel.Result) {
        NetAloSDK.initSetting(
            settingResponse = SettingResponse(
                apiEndpoint = EndPoint.URL_API,//string
                cdnEndpoint = EndPoint.URL_CDN,
                cdnEndpointSdk = call.arguments as? String ?: "",
                chatEndpoint = EndPoint.URL_SOCKET,
                turnserverEndpoint = EndPoint.URL_TURN
            )
        )
        result.success(true)
    }

    private fun setNetaloUser(call: MethodCall, result: MethodChannel.Result) {
        NetAloSDK.setNetAloUser(
            NeUser(
                id = call.argument("id") as? Long ?: 0,
                token = call.argument("token") as? String ?: "",
                username = call.argument("username") ?: "",
                avatar = call.argument("avatar") as? String ?: ""
            )
        )
        result.success(true)
    }

    private fun openChatConversation(call: MethodCall, result: MethodChannel.Result) {
        NetAloSDK.openNetAloSDK(this)
        result.success(true)
    }

    private fun openChatWithUser(call: MethodCall, result: MethodChannel.Result) {
        val target: HashMap<String, Any> = call.argument("target")!!
        NetAloSDK.openNetAloSDK(
            this,
            false,
            null,
            NeUser(
                id = target["id"] as? Long ?: 0,
                token = target["token"] as? String ?: "",
                username = target["username"] as? String ?: "",
                avatar = target["avatar"] as? String ?: ""
            )
        )
        result.success(true)
    }

    private fun closeNetAloChat() {
        NetAloSDK.exit()
    }

}
