import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class DetailPage extends StatelessWidget {
  DetailPage(
      {super.key,
      this.address,
      this.place_name,
      this.isRegister,
      this.isReviewed,
      this.category,
      this.review,
      this.matjipReview,
      this.isGuest = false});

  String? place_name;
  String? address;
  String? category;
  bool? isRegister;
  bool? isReviewed;
  Map<String, double>? review;
  bool isGuest;
  Map<String, Map<String, double>>? matjipReview;

  @override
  Widget build(BuildContext context) {
    double rating_ = 1.0;
    double matjipRating = 1.0;
    TextEditingController reviewField = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text("$place_name"),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              address ?? "",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w100),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        Visibility(
                            visible: !(isReviewed ?? false),
                            child: Column(
                              children: [
                                const Text(
                                  "후기 남기기",
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                RatingBar.builder(
                                    minRating: 1,
                                    initialRating: 1,
                                    allowHalfRating: true,
                                    itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                    onRatingUpdate: (rating) {
                                      rating_ = rating;
                                    }),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  controller: reviewField,
                                  decoration: const InputDecoration(
                                      hintText:
                                          "부적절하거나 불쾌감을 줄 수 있는 컨텐츠를 게시할 경우 제재를 받을 수 있습니다."),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      if (isGuest) {
                                        Get.snackbar(
                                            "error", "Guest는 사용할 수 없는 기능입니다");
                                        return;
                                      }
                                      if (reviewField.text.isEmpty) {
                                        Get.snackbar("error", "리뷰를 입력해주세요");
                                        return;
                                      }

                                      bool isUpdate = false;
                                      var review = Provider.of<UserModel>(
                                              context,
                                              listen: false)
                                          .review;

                                      for (var i in review.keys) {
                                        if (i == "$place_name&$address") {
                                          Get.snackbar(
                                              "error", "이미 리뷰를 등록한 맛집입니다");
                                          return;
                                        }
                                      }

                                      Map<String, double> registerReview = {};
                                      registerReview[reviewField.text] =
                                          rating_;

                                      Provider.of<UserModel>(context,
                                              listen: false)
                                          .addReview("$place_name&$address",
                                              registerReview);

                                      var li = Provider.of<UserModel>(context,
                                              listen: false)
                                          .review;

                                      var email =
                                          "${Provider.of<UserModel>(context, listen: false).email}&${Provider.of<UserModel>(context, listen: false).getSocialType()}";
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(
                                              "${Provider.of<UserModel>(context, listen: false).email}&${Provider.of<UserModel>(context, listen: false).getSocialType()}")
                                          .update({"review": li});

                                      // var test = await FirebaseFirestore.instance
                                      //     .collection("matjips")
                                      //     .get();

                                      await FirebaseFirestore.instance
                                          .collection("matjips")
                                          .doc("$place_name&$address")
                                          .set({
                                        email ?? "": {
                                          reviewField.text: rating_
                                        },
                                      }, SetOptions(merge: true));
                                      isUpdate = true;

                                      Get.back();
                                      Get.snackbar("Success", "등록 완료되었습니다");
                                    },
                                    child: const Text("등록하기")),
                              ],
                            )),
                        Visibility(
                            visible: isReviewed ?? false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("내 리뷰"),
                                const SizedBox(
                                  height: 20,
                                ),
                                for (var i in review?.keys ?? {""})
                                  Text("$i, 평점: ${review?[i]}"),
                              ],
                            )),

                        const SizedBox(
                          height: 100,
                        ),

                        for (var i in matjipReview?.keys ?? {"", ""})
                          for (var j in matjipReview?[i]?.keys ?? {"", ""}) ...[
                            ListTile(
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("사용자 차단하기"),
                                        content: const Text("사용자를 차단하시겠습니까?"),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: const Text("취소")),
                                          ElevatedButton(
                                              onPressed: () async {
                                                Provider.of<UserModel>(context,
                                                        listen: false)
                                                    .addBlockList(i);

                                                await FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(Provider.of<UserModel>(
                                                            context,
                                                            listen: false)
                                                        .email)
                                                    .set(
                                                        ({
                                                          "block": Provider.of<
                                                                      UserModel>(
                                                                  context,
                                                                  listen: false)
                                                              .block_list
                                                        }),
                                                        SetOptions(
                                                            merge: true));

                                                Get.back();
                                                Get.snackbar("완료", "차단되었습니다");
                                              },
                                              child: const Text("차단하기")),
                                        ],
                                      );
                                    });
                              },
                              title: Text(
                                "${i.split("&")[0].split("@")[0]} from ${i.split("&").last} 님",
                                style: const TextStyle(fontSize: 15),
                              ),
                              trailing: Column(
                                children: [
                                  Text(
                                    j,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  RatingBar.builder(
                                      minRating: 1,
                                      itemSize: 20,
                                      initialRating:
                                          matjipReview?[i]?[j] ?? 0.0,
                                      allowHalfRating: true,
                                      ignoreGestures: true,
                                      itemBuilder: (context, _) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                      onRatingUpdate: (rating) {
                                        rating_ = rating;
                                      }),
                                ],
                              ),
                            )
                          ],

                        // Text(review)
                      ])),
            ],
          ),
        ));
  }
}
