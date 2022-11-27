// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_sdk/model/neta_user.dart';
import 'package:flutter_sdk/platform_channel.dart';

class OptionsSdkPage extends StatelessWidget {
  final PlatformChannel platformChannel;

  const OptionsSdkPage({required this.platformChannel, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tùy chọn kết nối SDK"),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () async {
                await platformChannel.openCallWithUser(
                  user: NetaUser(
                      id: 4785074617633555,
                      phone: "maymaylam24",
                      username: "maymaylam24",
                      avatar: ""),
                );
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange)),
              child: const SizedBox(
                width: 250,
                height: 40,
                child: Center(
                    child: Text(
                  "Call with user",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () async {
                await platformChannel.openChatWithUser(
                  user: NetaUser(
                      id: 4785074617633555,
                      phone: "maymaylam24",
                      username: "maymaylam24",
                      avatar: ""),
                );
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange)),
              child: const SizedBox(
                width: 250,
                height: 40,
                child: Center(
                    child: Text(
                  "Show chat with user",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () async {
                await platformChannel.openListConversation();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange)),
              child: const SizedBox(
                width: 250,
                height: 40,
                child: Center(
                    child: Text(
                  "Show ist conversation",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () async {
                await platformChannel.logoutSDK();
                Navigator.pop(context);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange)),
              child: const SizedBox(
                width: 250,
                height: 40,
                child: Center(
                    child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
