import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/matjip.dart';
import '../model/usermodel.dart';

class FindFollowersPage extends StatefulWidget {
  FindFollowersPage({super.key, this.findAllUser, this.isGuest = false});

  List<String>? findAllUser = [];
  bool isGuest;
  @override
  State<FindFollowersPage> createState() => _FindFollowersPageState();
}

class _FindFollowersPageState extends State<FindFollowersPage> {
  late List<bool> isEnabled =
      List.filled(widget.findAllUser?.length ?? 0, true);
  late List<bool> boolList;
  bool isVisible = false;
  bool isSearch = false;
  List<MatJip> temp = [];
  Map<String, List<MatJip>> searchUserMatjipList = {};

  onPressedFunc(
      int index, String email, bool isGuest, List<bool> indexBool) async {
    if (isGuest) {
      Get.snackbar("error", "Guest는 사용할 수 없는 기능입니다");
      return;
    }
    if (indexBool[index]) {
      var following = Provider.of<UserModel>(context, listen: false).following;
      if (!following.contains(email)) {
        following.add(email);
        await FirebaseFirestore.instance
            .collection("users")
            .doc("${Provider.of<UserModel>(context, listen: false).email}")
            .update({"following": following});
        Provider.of<UserModel>(context, listen: false).addFollowing(email);
        if (isSearch) {
          boolList[index] = false;
        } else {
          isEnabled[index] = false;
        }
      } else {
        Get.snackbar("error", "이미 팔로우 하는 유저입니다");
        return;
      }
    } else {
      if (isSearch) {
        boolList[index] = true;
      } else {
        isEnabled[index] = true;
      }
    }
    setState(() {});
  }

  search(String search) async {
    var snap = await FirebaseFirestore.instance.collection('users').get();
    var result = snap.docs;
    isSearch = true;

    for (var i in result) {
      if ((i.id).split("@")[0] == search &&
          !Provider.of<UserModel>(context, listen: false)
              .block_list
              .contains(i.id) &&
          !Provider.of<UserModel>(context, listen: false)
              .following
              .contains(i.id)) {
        var gets = i.data()['matjip'];

        if (gets != null) {
          for (var j in gets) {
            // matjipList.add(i);
            temp.add(MatJip(
                place_name: j["place_name"],
                x: j["x"],
                y: j["y"],
                address: j["address"],
                category: j["category"]));
          }
        }
        searchUserMatjipList[i.id] = temp;
        temp = [];
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int? count = widget.findAllUser?.length;

    TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Follower 찾기",
          style: TextStyle(letterSpacing: 3.0, fontSize: 14),
        ),
        actions: [
          IconButton(
              onPressed: () {
                isVisible = !isVisible;
                setState(() {});
              },
              icon: const Icon(Icons.person_search_rounded))
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          setState(() {});
        },
        child: Column(
          children: [
            Visibility(
                visible: isVisible,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) async {
                            controller.text = value;
                            await search(controller.text);
                          },
                          controller: controller,
                          decoration: InputDecoration(
                              hintText: "검색어를 입력하세요",
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    controller.text = "";
                                    isSearch = false;
                                    isVisible = false;
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.cancel))),
                        ),
                      ),
                      IconButton(
                          onPressed: () async => await search(controller.text),
                          icon: const Icon(Icons.search))
                    ],
                  ),
                )),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              visible: !isSearch,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: count ?? 0,
                  itemBuilder: (context, index) {
                    var keys = widget.findAllUser?.toList() ?? [];

                    return ListTile(
                        leading: const Icon(Icons.people),
                        title: Text(
                            "${keys[index].split("@")[0]} from ${keys[index].split("&").last}"),
                        trailing: Wrap(
                          children: [
                            ElevatedButton(
                              onPressed: isEnabled[index]
                                  ? () => onPressedFunc(index, keys[index],
                                      widget.isGuest, isEnabled)
                                  : null,
                              style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black12)),
                              child: const Text("Follow"),
                            ),
                            IconButton(
                                onPressed: () {
                                  widget.findAllUser?.remove(keys[index]);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.cancel))
                          ],
                        ));
                  }),
            ),
            Visibility(
                visible: isSearch,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchUserMatjipList.keys.length,
                    itemBuilder: (context, index) {
                      var keys = searchUserMatjipList.keys.toList();
                      boolList =
                          List.filled(searchUserMatjipList.keys.length, true);

                      return ListTile(
                        leading: const Icon(Icons.people),
                        title: Text(
                            "${keys[index].split("@")[0]} from ${keys[index].split("&").last}"),
                        trailing: Wrap(
                          children: [
                            ElevatedButton(
                              onPressed: boolList[index]
                                  ? () => onPressedFunc(index, keys[index],
                                      widget.isGuest, boolList)
                                  : null,
                              style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black12)),
                              child: const Text("Follow"),
                            ),
                            IconButton(
                                onPressed: () {
                                  searchUserMatjipList.remove(keys[index]);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.cancel))
                          ],
                        ),
                      );
                    })),
          ],
        ),
      ),
    );
  }
}
