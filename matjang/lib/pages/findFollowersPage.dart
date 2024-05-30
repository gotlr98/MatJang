import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindFollowersPage extends StatefulWidget {
  const FindFollowersPage({super.key});

  @override
  State<FindFollowersPage> createState() => _FindFollowersPageState();
}

class _FindFollowersPageState extends State<FindFollowersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: const Text("test"),
            onTap: () {
              print(Get.arguments["followers"]);
            },
          ),
        ],
      ),
    );
  }
}
