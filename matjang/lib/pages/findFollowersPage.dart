import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/matjip.dart';
import '../model/usermodel.dart';

class FindFollowersPage extends StatefulWidget {
  FindFollowersPage({super.key, this.allUserMatjipList});

  Map<String, List<MatJip>>? allUserMatjipList = {};
  @override
  State<FindFollowersPage> createState() => _FindFollowersPageState();
}

class _FindFollowersPageState extends State<FindFollowersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Follower 찾기")),
      body: Column(children: [
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
        for (var i in widget.allUserMatjipList!.keys)
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.allUserMatjipList!.keys.length,
            itemBuilder: (context, index) {
              return ListTile(
                  // enabled: true,
                  // selected: true,
                  leading: const Icon(Icons.people),
                  title: Text("${i.split("@")[0]} 님"),
                  subtitle:
                      Text("${widget.allUserMatjipList![i]!.length} 개 후기"),
                  trailing: Wrap(
                    children: [
                      ElevatedButton(
                          onPressed: () {}, child: const Text("Follow")),
                      IconButton(
                          onPressed: () {
                            widget.allUserMatjipList!.remove(i);
                            setState(() {});
                          },
                          icon: const Icon(Icons.cancel))
                    ],
                  ));
            },
          )
      ]),
    );
  }
}
