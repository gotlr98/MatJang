import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class RegisterBookMark extends StatefulWidget {
  RegisterBookMark({super.key, this.bookmarkTitle});

  @override
  State<RegisterBookMark> createState() => _RegisterBookMarkState();

  List<String>? bookmarkTitle;
}

class _RegisterBookMarkState extends State<RegisterBookMark> {
  TextEditingController inputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          TextField(
            controller: inputController,
            decoration: const InputDecoration(labelText: "그룹명을 입력해주세요"),
          ),
          const SizedBox(height: 100),
          ElevatedButton(
            onPressed: () async {
              if (inputController.text.isEmpty) {
                Get.snackbar("error", "그룹명을 입력해 주세요");
                return;
              } else if (widget.bookmarkTitle?.contains(inputController.text) ??
                  false) {
                Get.snackbar("error", "이미 존재하는 그룹명입니다");
                return;
              } else {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(Provider.of<UserModel>(context, listen: false).email!)
                    .collection("matjip")
                    .doc("bookmark")
                    .set({inputController.text: []}, SetOptions(merge: true));

                // var snap = await FirebaseFirestore.instance.collection("users").doc(Provider.of<UserModel>(context, listen: false).email!)
                //     .collection("matjip")
                //     .doc("bookmark").get();

                // var result = snap.data();

                Get.back();
              }
            },
            child: const Text("등록하기"),
          )
        ],
      ),
    ));
  }
}
