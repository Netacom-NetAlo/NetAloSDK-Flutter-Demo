import 'package:flutter/services.dart';
import 'package:flutter_sdk/model/neta_user.dart';

class PlatformChannel {
  final channel =
      const MethodChannel("com.netacom.flutter_sdk/flutter_channel");
  final handleNativeChannel = const MethodChannel('callbacks');

  Future<void> setSdkUser({required NetaUser user}) async {
    await channel.invokeMethod("setSdkUser", user.toJson());
  }

  Future<void> openCallWithUser({required NetaUser user}) async {
    await channel.invokeMethod("openCallWithUser", user.toJson());
  }

  Future<void> openChatWithUser({required NetaUser user}) async {
    await channel.invokeMethod("openChatWithUser", user.toJson());
  }

  Future<void> openListConversation() async {
    await channel.invokeMethod("openListConversation");
  }

  Future<void> logoutSDK() async {
    await channel.invokeMethod("logoutSDK");
  }
}
