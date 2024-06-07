import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class UserOwnReviewPage extends StatefulWidget {
  const UserOwnReviewPage({super.key});

  @override
  State<UserOwnReviewPage> createState() => _UserOwnReviewPageState();
}

class _UserOwnReviewPageState extends State<UserOwnReviewPage> {
  Map<String, Map<String, double>> get_matjip_review = {};

  _getUserMatjipsReview() async {
    var snap = await FirebaseFirestore.instance.collection("users").get();

    var result = snap.docs;

    for (var i in result) {
      if (i.id == Get.arguments["email"]) {
        var getReview = i.data()["review"];
        if (getReview != null) {
          for (var i in getReview.keys) {
            Map<String, double> temp = {};
            String rev = getReview[i]
                .keys
                .toString()
                .replaceAll("(", "")
                .replaceAll(")", "");
            double rat = double.parse(getReview[i]
                .values
                .toString()
                .replaceAll("(", "")
                .replaceAll(")", ""));

            temp[rev] = rat;
            get_matjip_review[i] = temp;
          }
        }

        if (get_matjip_review.isNotEmpty) {
          Provider.of<UserModel>(context, listen: false)
              .getReviewFromFirebase(get_matjip_review);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserMatjipsReview();

      get_matjip_review = Provider.of<UserModel>(context, listen: false).review;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text("내 리뷰"),
          for (var i in get_matjip_review.keys) Text(i.split("&")[0])
        ],
      ),
    );
  }
}
