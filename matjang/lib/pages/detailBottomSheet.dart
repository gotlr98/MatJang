import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matjang/model/usermodel.dart';

class DetailBottomSheet extends StatelessWidget {
  DetailBottomSheet({super.key, this.place_name, this.address, this.category});
  String? place_name;
  String? address;
  String? category;

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
                              onPressed: () {}, child: const Text("등록하기")),
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
