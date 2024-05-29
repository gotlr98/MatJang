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
      this.review});

  String? place_name;
  String? address;
  String? category;
  bool? isRegister;
  bool? isReviewed;
  var review;

  @override
  Widget build(BuildContext context) {
    double rating_ = 1.0;
    TextEditingController reviewField = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text("$place_name"),
        ),
        body: Column(
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
                            address!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w100),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      const Text("후기 남기기"),
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
                      TextField(controller: reviewField),
                      ElevatedButton(
                          onPressed: () async {
                            if (reviewField.text.isEmpty) {
                              Get.snackbar("error", "리뷰를 입력해주세요");
                              return;
                            }
                            bool isUpdate = false;
                            var review =
                                Provider.of<UserModel>(context, listen: false)
                                    .review;

                            for (var i in review.keys) {
                              if (i == "$place_name&$address") {
                                Get.snackbar("error", "이미 리뷰를 등록한 맛집입니다");
                                return;
                              }
                            }

                            Map<String, double> registerReview = {};
                            registerReview[reviewField.text] = rating_;

                            Provider.of<UserModel>(context, listen: false)
                                .addReview(
                                    "$place_name&$address", registerReview);

                            var li =
                                Provider.of<UserModel>(context, listen: false)
                                    .review;

                            var email =
                                Provider.of<UserModel>(context, listen: false)
                                    .email;
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(Provider.of<UserModel>(context,
                                        listen: false)
                                    .email)
                                .update({"review": li});

                            var test = await FirebaseFirestore.instance
                                .collection("matjips")
                                .get();
                            if (test.docs.isEmpty) {
                              print("blank");
                            } else {
                              for (var i in test.docs) {
                                if (i.id == "$place_name&$address") {
                                  print("doing update");
                                  await FirebaseFirestore.instance
                                      .collection("matjips")
                                      .doc("$place_name&$address")
                                      .update({
                                    email!: {reviewField.text: rating_}
                                  });
                                  isUpdate = true;
                                }
                              }
                              if (!isUpdate) {
                                await FirebaseFirestore.instance
                                    .collection("matjips")
                                    .doc("$place_name&$address")
                                    .set({
                                  email!: {reviewField.text: rating_}
                                });
                              }
                            }

                            Get.snackbar("Success", "등록 완료되었습니다");
                            Get.back();
                          },
                          child: const Text("등록하기")),
                      const SizedBox(
                        height: 100,
                      ),

                      ElevatedButton(
                          onPressed: () async {
                            var test = await FirebaseFirestore.instance
                                .collection("matjips")
                                .get();
                            if (test.docs.isEmpty) {
                              print("black");
                            } else {
                              for (var i in test.docs) {
                                print(i.id);
                              }
                            }
                          },
                          child: const Text("check data"))
                      // Text(review)
                    ])),
          ],
        ));
  }
}
