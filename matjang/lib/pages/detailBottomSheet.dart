import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:matjang/model/matjip.dart';
import 'package:matjang/model/usermodel.dart';
import 'package:provider/provider.dart';

class DetailBottomSheet extends StatefulWidget {
  DetailBottomSheet(
      {super.key,
      this.place_name,
      this.address,
      this.category,
      this.x,
      this.y,
      this.isRegister = false,
      this.isGuest = false});
  String? place_name;
  String? address;
  String? category;
  String? x;
  String? y;
  bool isRegister;
  bool isGuest;

  @override
  State<DetailBottomSheet> createState() => _DetailBottomSheetState();
}

class _DetailBottomSheetState extends State<DetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              children: [
                Text(
                  widget.place_name ?? "",
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w200),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  widget.category ?? "",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w100),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              widget.address ?? "",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w100),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: !widget.isGuest,
                  child: IconButton(
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          title: const Text("맛집 등록하기"),
                          content: const Text("맛집에 등록하시겠습니까?"),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  var getList = Provider.of<UserModel>(context,
                                          listen: false)
                                      .matjipList;
                                  for (var i in getList) {
                                    if (i.place_name == widget.place_name &&
                                        i.address == widget.address) {
                                      Get.back();
                                      Get.snackbar("중복", "이미 등록된 맛집입니다",
                                          duration: const Duration(seconds: 2));
                                      return;
                                    }
                                  }
                                  Provider.of<UserModel>(context, listen: false)
                                      .addList(MatJip(
                                          place_name: widget.place_name,
                                          x: widget.x,
                                          y: widget.y,
                                          address: widget.address,
                                          category: widget.category));

                                  var result = Provider.of<UserModel>(context,
                                          listen: false)
                                      .matjipList;
                                  var li = [];
                                  for (var i in result) {
                                    li.add(MatJip().toJson(i));
                                  }

                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(
                                          "${Provider.of<UserModel>(context, listen: false).email}&${Provider.of<UserModel>(context, listen: false).getSocialType()}")
                                      .update({"matjip": li});
                                  Get.back();

                                  Get.snackbar("Success", "등록완료");

                                  setState(() {
                                    widget.isRegister = true;
                                  });
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
                      icon: widget.isRegister
                          ? const Icon(Icons.check)
                          : const Icon(Icons.bookmark)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
