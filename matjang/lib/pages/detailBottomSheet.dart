import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:matjang/model/matjip.dart';
import 'package:matjang/model/usermodel.dart';
import 'package:matjang/pages/bookmarkBottomsheet.dart';
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
      this.checkBookmarkRegister,
      this.isGuest = false});
  String? place_name;
  String? address;
  String? category;
  String? x;
  String? y;
  bool isRegister;
  Map<String, bool>? checkBookmarkRegister;
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
            Row(
              children: [
                Flexible(
                  child: Text(
                    widget.place_name ?? "",
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w200),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      widget.category ?? "",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w100),
                    ),
                  ],
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
                      onPressed: () async {
                        // Get.dialog(AlertDialog(
                        //   title: const Text("맛집 등록하기"),
                        //   content: const Text("맛집에 등록하시겠습니까?"),
                        //   actions: [
                        //     TextButton(
                        //         onPressed: () async {
                        //           var getList = Provider.of<UserModel>(context,
                        //                   listen: false)
                        //               .matjipList;
                        //           for (var i in getList) {
                        //             if (i.place_name == widget.place_name &&
                        //                 i.address == widget.address) {
                        //               Get.back();
                        //               Get.snackbar("중복", "이미 등록된 맛집입니다",
                        //                   duration: const Duration(seconds: 2));
                        //               return;
                        //             }
                        //           }
                        //           Provider.of<UserModel>(context, listen: false)
                        //               .addList(MatJip(
                        //                   place_name: widget.place_name,
                        //                   x: widget.x,
                        //                   y: widget.y,
                        //                   address: widget.address,
                        //                   category: widget.category));

                        //           var result = Provider.of<UserModel>(context,
                        //                   listen: false)
                        //               .matjipList;
                        //           var li = [];
                        //           for (var i in result) {
                        //             li.add(MatJip().toJson(i));
                        //           }

                        //           await FirebaseFirestore.instance
                        //               .collection("users")
                        //               .doc(
                        //                   "${Provider.of<UserModel>(context, listen: false).email}")
                        //               .update({"matjip": li});
                        //           Get.back();

                        //           Get.snackbar("Success", "등록완료");

                        //           setState(() {
                        //             widget.isRegister = true;
                        //           });
                        //         },
                        //         child: const Text("등록하기")),
                        //     TextButton(
                        //         onPressed: () {
                        //           Get.back();
                        //         },
                        //         child: const Text("취소하기"))
                        //   ],
                        // ));
                        var email =
                            Provider.of<UserModel>(context, listen: false)
                                .email;
                        // print(widget.place_name);
                        // print(widget.x);
                        // print(widget.y);
                        // print(widget.address);
                        // print(widget.category);
                        var snap = await FirebaseFirestore.instance
                            .collection("users")
                            .doc(email)
                            .collection("matjip")
                            .doc("bookmark")
                            .get();
                        var result = snap.data();
                        List<MatJip> temp = [];
                        Map<String, List<MatJip>> bookmark = {};

                        if (result?.isNotEmpty ?? false) {
                          for (var i in result?.keys ?? {"", ""}) {
                            for (var j = 0; j < result?[i].length; j++) {
                              temp.add(MatJip.fromJson(result?[i][j]));
                            }
                            bookmark[i] = temp;
                            temp = [];
                          }
                        }

                        // for (var i in result) {
                        //   if (i.id ==
                        //       Provider.of<UserModel>(context, listen: false)
                        //           .email) {
                        //     var temp = Map<String, List<MatJip>>.from(
                        //         i.data()["matjip"]);
                        //     if (temp.isNotEmpty) {
                        //       for (var j in temp.keys) {
                        //         bookmark[j] = temp[j] ?? [];
                        //       }
                        //     }
                        //   }
                        // }
                        Get.bottomSheet(BookmarkBottomsheet(
                          bookmark: bookmark,
                          matjip: MatJip(
                            place_name: widget.place_name,
                            x: widget.x,
                            y: widget.y,
                            address: widget.address,
                            category: widget.category,
                          ),
                          checkBookmarkRegister: widget.checkBookmarkRegister,
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
