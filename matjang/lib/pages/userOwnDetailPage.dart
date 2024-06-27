import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class UserOwnDetailPage extends StatefulWidget {
  UserOwnDetailPage({super.key, this.review, this.following});

  @override
  State<UserOwnDetailPage> createState() => _UserOwnDetailPageState();
  Map<String, Map<String, double>>? review = {};
  List<String>? following = [];
}

class _UserOwnDetailPageState extends State<UserOwnDetailPage> {
  static const storage = FlutterSecureStorage(
      iOptions: IOSOptions(
    synchronizable: false,
    accessibility: KeychainAccessibility.first_unlock,
  ));
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double rating_ = 1.0;
    TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "내정보",
            style: TextStyle(letterSpacing: 3.0, fontSize: 14),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return PopScope(
                          // canPop: ,
                          child: AlertDialog(
                            title: const Text("신고하기"),
                            content: TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                  hintText: "신고할 유저의 이메일을 입력하세요"),
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text("취소하기")),
                              ElevatedButton(
                                  onPressed: () {
                                    if (textController.text.isNotEmpty &&
                                        textController.text.contains("@")) {
                                      Get.back();
                                      Get.snackbar("성공", "신고되었습니다");
                                    } else {
                                      Get.snackbar("Error", "이메일을 입력해주세요");
                                    }
                                  },
                                  child: const Text("신고하기"))
                            ],
                          ),
                        );
                      });
                },
                icon: const Icon(Icons.notification_important)),
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("탈퇴하기"),
                          content: const Text("정말 탈퇴하시겠습니까?"),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text("취소")),
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(Provider.of<UserModel>(context,
                                            listen: false)
                                        .email)
                                    .delete();
                                await storage.delete(
                                    key:
                                        "login-${Provider.of<UserModel>(context, listen: false).getSocialType()}");
                                Provider.of<UserModel>(context, listen: false)
                                    .withDrawerAccount();

                                Get.offAllNamed("/login");
                              },
                              child: const Text("예"),
                            )
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.person_off))
          ]),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                "내 리뷰",
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(
                height: 15,
              ),
              for (var i in widget.review?.keys ?? {"null", "null"}) ...[
                Text(i.split("&")[0]),
                const SizedBox(height: 8),
                for (var j in widget.review![i]!.values) ...[
                  RatingBar.builder(
                    minRating: 1,
                    initialRating: double.parse(
                        (j).toString().replaceAll("(", "").replaceAll(")", "")),
                    allowHalfRating: true,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      rating_ = rating;
                    },
                    ignoreGestures: true,
                    itemSize: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                      "${(widget.review?[i]?.keys).toString().replaceAll("(", "").replaceAll(")", "")} "),
                  const Divider(
                    thickness: 1,
                  ),
                ]
              ],
              const SizedBox(height: 50),
              const Text(
                "내 맛집",
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 15),
              //   DropdownButton(value: selectedValue,
              // items: selectList.map(
              //   (value) {
              //     return DropdownMenuItem(
              //       value: value,
              //       child: Text(value),
              //     );
              //   },
              // ).toList(),
              // onChanged: (value) {
              //   setState(() {
              //     selectedValue = value ?? "";

              //   });
              // },),
              const Text("팔로잉", style: TextStyle(fontSize: 25)),
              const SizedBox(height: 15),
              for (var i in widget.following ?? [])
                Text("${i.split("@")[0]}님 from ${i.split("&").last}"),
              const SizedBox(
                height: 50,
              ),
              const Text("차단 리스트", style: TextStyle(fontSize: 25)),
              const SizedBox(height: 15),
              for (var i
                  in Provider.of<UserModel>(context, listen: false).block_list)
                Text("${i.split("@")[0]} from ${i.split("&").last}")
            ],
          ),
        ),
      ),
    );
  }
}
