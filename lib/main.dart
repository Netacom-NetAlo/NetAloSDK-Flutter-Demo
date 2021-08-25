import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sdk/net_alo_user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter NetAlo SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

enum GalleryType { all, image, video }

extension GalleryTypeExt on GalleryType {
  int get type {
    switch (this) {
      case GalleryType.all:
        return 0;
      case GalleryType.image:
        return 1;
      case GalleryType.video:
        return 2;
      default:
        return 1;
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('com.netacom.flutter_sdk/flutter_channel');

  @override
  void initState() {
    super.initState();
    initUser();
  }

  void initUser() async {
    await platform.invokeMethod(
        "setNetaloUser",
        NetAloUser(
            id: "3940649674873365",
            token: "e61754c0a70409ef59aeaadd5643bb177bf883ce",
            avatar: "a6hIg_MRfWKSPeAXkkxAjA6coypt1y6j1KtJAkbd9k_E2w46wZuU4mbhNvA4Uzdl",
            username: "UserA",
            phone: "+84101143002",
            isAdmin: false)
            .toJson());
  }

  void openChatUser() async {
    await platform.invokeMethod(
        "openChatWithUser",
        NetAloUser(
            id: "3940649674873367",
            token: "",
            avatar: "a6hIg_MRfWKSPeAXkkxAjA6coypt1y6j1KtJAkbd9k_E2w46wZuU4mbhNvA4Uzdl",
            username: "UserB",
            phone: "+84101143001",
            isAdmin: false)
            .toJson());
  }

  void openListConversation() async {
    await platform.invokeMethod(
        "openChatConversation",
        NetAloUser(
            id: "3940649674873367",
            token: "",
            avatar: "a6hIg_MRfWKSPeAXkkxAjA6coypt1y6j1KtJAkbd9k_E2w46wZuU4mbhNvA4Uzdl",
            username: "UserB",
            phone: "+84101143001",
            isAdmin: false)
            .toJson());
  }

  void openGallery() async {
    final result = await platform.invokeMethod("pickImages", {
      "maxImages": 6,
      "type": 0,
      "autoDismissOnMaxSelections": false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Demo SDK Flutter',
             style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            ElevatedButton(onPressed: () => openListConversation(), child: Text('Open Chat Conversation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),)),
            ElevatedButton(onPressed: () => openChatUser(), child: Text('Open Chat User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),)),
            ElevatedButton(onPressed: () => openGallery(), child: Text('Open Gallery', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),))
          ],
        ),
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
