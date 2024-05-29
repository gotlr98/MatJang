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
                          onPressed: () {
                            var review =
                                Provider.of<UserModel>(context, listen: false)
                                    .review;

                            for (var i in review.keys) {
                              if (i == "$place_name&$address") {
                                Get.snackbar("error", "이미 리뷰를 등록한 맛집입니다");
                              }
                            }
                          },
                          child: const Text("등록하기")),
                      const SizedBox(
                        height: 100,
                      ),
                      // Text(review)
                    ])),
          ],
        ));
  }
}
