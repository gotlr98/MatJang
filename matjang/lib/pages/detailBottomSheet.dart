import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matjang/model/matjip.dart';
import 'package:matjang/model/usermodel.dart';
import 'package:provider/provider.dart';

class DetailBottomSheet extends StatelessWidget {
  DetailBottomSheet(
      {super.key,
      this.place_name,
      this.address,
      this.category,
      this.x,
      this.y});
  String? place_name;
  String? address;
  String? category;
  String? x;
  String? y;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  place_name!,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w200),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  category!,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w100),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              address!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w100),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Get.dialog(AlertDialog(
                        title: const Text("맛집 등록하기"),
                        content: const Text("맛집에 등록하시겠습니까?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Provider.of<UserModel>(context, listen: false)
                                    .addList(MatJip(
                                        place_name: place_name,
                                        x: x,
                                        y: y,
                                        address: address,
                                        category: category));
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(Provider.of<UserModel>(context,
                                            listen: false)
                                        .email)
                                    .set({
                                  "matjip": [
                                    {
                                      "place_name": place_name,
                                      "x": x,
                                      "y": y,
                                      "address": address,
                                      "category": category
                                    }
                                  ]
                                });

                                Get.back();
                              },
                              child: const Text("등록하기")),
                          TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("취소하기"))
                        ],
                      ));
                    },
                    icon: const Icon(Icons.bookmark))
              ],
            )
          ],
        ),
      ),
    );
  }
}
