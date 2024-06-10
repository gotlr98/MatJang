import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class UserOwnReviewPage extends StatefulWidget {
  UserOwnReviewPage({super.key, this.review, this.following});

  @override
  State<UserOwnReviewPage> createState() => _UserOwnReviewPageState();
  Map<String, Map<String, double>>? review = {};
  List<String>? following = [];
}

class _UserOwnReviewPageState extends State<UserOwnReviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내정보"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          const Text("내 리뷰"),
          const SizedBox(
            height: 15,
          ),
          for (var i in widget.review!.keys)
            Text(
                "${i.split("&")[0]}: ${widget.review![i]!.keys}, 평점: ${widget.review![i]!.values}"),
          const SizedBox(height: 15),
          const Text("팔로잉"),
          const SizedBox(height: 15),
          for (var i in widget.following!) Text(i)
        ],
      ),
    );
  }
}
