import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class FindFollowersPage extends StatefulWidget {
  const FindFollowersPage({super.key});

  @override
  State<FindFollowersPage> createState() => _FindFollowersPageState();
}

class _FindFollowersPageState extends State<FindFollowersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Follower 찾기")),
      body: Column(
        children: [
          // for (var i in Get.arguments["followers"].keys)
          //   Container(
          //     decoration: BoxDecoration(
          //         border: Border.all(color: Colors.black, width: 3),
          //         borderRadius: BorderRadius.circular(10)),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         Text("${i.split("@")[0]} 님"),
          //         for (var j in Get.arguments["followers"][i])
          //           Column(
          //             children: [
          //               Text(j.place_name),
          //               Text(j.address),
          //             ],
          //           )
          //       ],
          //     ),
          //   ),
          for (var i in Get.arguments["followers"].keys)
            SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                            "${(Provider.of<UserModel>(context, listen: false).email!).split("@")[0]} 님을 위한 추천"),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people),
                        const SizedBox(width: 30),
                        Column(
                          children: [
                            Text(i.split("@")[0]),
                            Text("후기 ${Get.arguments["followers"][i].length} 개")
                          ],
                        ),
                        const SizedBox(width: 90),
                        ElevatedButton(
                            onPressed: () {}, child: const Text("Follow")),
                        IconButton(
                            onPressed: () {}, icon: const Icon(Icons.cancel))
                      ],
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
