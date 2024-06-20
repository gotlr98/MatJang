import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class RegisterBookMark extends StatefulWidget {
  const RegisterBookMark({super.key});

  @override
  State<RegisterBookMark> createState() => _RegisterBookMarkState();
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
                Get.snackbar("오류", "그룹명을 입력해 주세요");
                return;
              } else {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(Provider.of<UserModel>(context, listen: false).email!)
                    .set({
                  "matjip": {inputController.text: {}}
                }, SetOptions(merge: true));

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
