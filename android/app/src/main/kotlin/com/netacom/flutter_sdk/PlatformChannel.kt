package com.netacom.flutter_sdk

import com.asia.sdkcore.entity.ui.user.NeUser
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import com.netacom.flutter_sdk.callback.OnCheckFriendListener

class PlatformChannel {
    private lateinit var sendChannel: MethodChannel
    private val sendChannelName = "callbacks"
    lateinit var receiveChannel: MethodChannel
    private val receiveChannelName = "com.netacom.flutter_sdk/flutter_channel"

    companion object {
        var instance = PlatformChannel()
    }

    fun init(binaryMessenger: BinaryMessenger) {
        sendChannel = MethodChannel(binaryMessenger, sendChannelName)
        receiveChannel = MethodChannel(binaryMessenger, receiveChannelName)
    }

    fun sendEventNetAloSessionExpire() {
        sendChannel.invokeMethod("netAloSessionExpire", null)
    }

    fun sendEventNetAloPushNotification(data: Map<String, String>) {
        sendChannel.invokeMethod("netAloPushNotification", data)
    }

    fun sendEventNetAloChatPushNotification(data: NeUser) {
        sendChannel.invokeMethod("netAloChatPushNotification", data)
    }

    fun sendEventDeepLink(url:String?){
        sendChannel.invokeMethod("sendEventDeepLink", url)
    }

    fun sendEventHandleLinkFromNetAlo(url:String?){
        sendChannel.invokeMethod("sendEventHandleLinkFromNetAlo", url)
    }

    fun sendEventCheckIsFriend(targetNetAloId: Long? = 0L, callBack: OnCheckFriendListener){
        sendChannel.invokeMethod("checkIsFriend", targetNetAloId, object : MethodChannel.Result {
            override fun success(result: Any?) {
                result?.let {
                    callBack.onChecked(it as Boolean)
                }
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callBack.onChecked(false)
            }

            override fun notImplemented() {
            }

        })
    }
}