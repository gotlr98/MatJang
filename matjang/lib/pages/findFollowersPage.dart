import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/matjip.dart';
import '../model/usermodel.dart';

class FindFollowersPage extends StatefulWidget {
  FindFollowersPage({super.key, this.allUserMatjipList, this.isGuest = false});

  Map<String, List<MatJip>>? allUserMatjipList = {};
  bool isGuest;
  @override
  State<FindFollowersPage> createState() => _FindFollowersPageState();
}

class _FindFollowersPageState extends State<FindFollowersPage> {
  late List<bool> isEnabled =
      List.filled(widget.allUserMatjipList?.keys.length ?? 0, true);

  onPressedFunc(int index, String email, bool isGuest) async {
    if (isGuest) {
      Get.snackbar("error", "Guest는 사용할 수 없는 기능입니다");
      return;
    }
    if (isEnabled[index]) {
      var following = Provider.of<UserModel>(context, listen: false).following;
      following.add(email);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(
              "${Provider.of<UserModel>(context, listen: false).email}&${Provider.of<UserModel>(context, listen: false).getSocialType()}")
          .update({"following": following});
      Provider.of<UserModel>(context, listen: false).addFollowing(email);
      isEnabled[index] = false;
    } else {
      isEnabled[index] = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Follower 찾기",
        style: TextStyle(letterSpacing: 3.0, fontSize: 14),
      )),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allUserMatjipList?.keys.length ?? 0,
          itemBuilder: (context, index) {
            var keys = widget.allUserMatjipList?.keys.toList() ?? [];
            if (keys.isNotEmpty) {
              return ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(
                      "${keys[index].split("@")[0]} from ${keys[index].split("&").last}"),
                  subtitle: Text(
                      "${widget.allUserMatjipList?[keys[index]]?.length} 개 후기"),
                  trailing: Wrap(
                    children: [
                      ElevatedButton(
                        onPressed: isEnabled[index]
                            ? () => onPressedFunc(
                                index, keys[index], widget.isGuest)
                            : null,
                        style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(
                                Colors.black12)),
                        child: const Text("Follow"),
                      ),
                      IconButton(
                          onPressed: () {
                            widget.allUserMatjipList?.remove(keys[index]);
                            setState(() {});
                          },
                          icon: const Icon(Icons.cancel))
                    ],
                  ));
            } else {
              return const Text("팔로우 할 유저가 없습니다");
            }
          },
        ),
      ),
    );
  }
}
