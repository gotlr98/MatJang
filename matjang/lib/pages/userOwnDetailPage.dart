import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class UserOwnDetailPage extends StatefulWidget {
  UserOwnDetailPage({super.key, this.review, this.following});

  @override
  State<UserOwnDetailPage> createState() => _UserOwnDetailPageState();
  Map<String, Map<String, double>>? review = {};
  List<String>? following = [];
}

class _UserOwnDetailPageState extends State<UserOwnDetailPage> {
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
                icon: const Icon(Icons.notification_important))
          ]),
      body: Container(
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
            for (var i in widget.review?.keys ?? {"null", "null"})
              Text(i.split("&")[0]),
            const SizedBox(height: 8),
            for (var i in widget.review?.keys ?? {"null", "null"})
              RatingBar.builder(
                minRating: 1,
                initialRating: double.parse((widget.review?[i]?.values)
                    .toString()
                    .replaceAll("(", "")
                    .replaceAll(")", "")),
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
            for (var i in widget.review?.keys ?? {"null", "null"})
              Text(
                  "${(widget.review?[i]?.keys).toString().replaceAll("(", "").replaceAll(")", "")} "),

            // ${(widget.review?[i]?.values).toString().replaceAll("(", "").replaceAll(")", "")} 평점

            //"${(widget.review?[i]?.keys).toString().replaceAll("(", "").replaceAll(")", "")} " 리뷰
            const SizedBox(height: 50),
            const Text("팔로잉", style: TextStyle(fontSize: 25)),
            const SizedBox(height: 15),
            for (var i in widget.following ?? [])
              Text("${i.split("@")[0]}님 from ${i.split("&").last}")
          ],
        ),
      ),
    );
  }
}
