import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matjang/pages/registerBookmark.dart';
import 'package:provider/provider.dart';

import '../model/matjip.dart';
import '../model/usermodel.dart';

class BookmarkBottomsheet extends StatefulWidget {
  BookmarkBottomsheet(
      {super.key, this.bookmark, this.matjip, this.checkBookmarkRegister});

  @override
  State<BookmarkBottomsheet> createState() => _BookmarkBottomsheetState();

  Map<String, List<MatJip>>? bookmark;
  MatJip? matjip;
  Map<String, bool>? checkBookmarkRegister;

  init() {
    print(checkBookmarkRegister!.keys);
  }
}

class _BookmarkBottomsheetState extends State<BookmarkBottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i in widget.bookmark?.keys ?? {"", ""}) ...[
            ListTile(
              title: Text(i),
              subtitle:
                  Text("${widget.bookmark?[i]?.length.toString()}개" ?? "null"),
              onTap: () {
                Get.dialog(AlertDialog(
                  title: const Text("등록하시겠습니까?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("취소")),
                    TextButton(
                        onPressed: () async {
                          print(widget.checkBookmarkRegister?[i]);
                          if (widget.checkBookmarkRegister?[i] ?? false) {
                            Get.back();
                            Get.snackbar("error", "이미 등록되어있습니다",
                                duration: const Duration(seconds: 1));
                            return;
                          }
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(
                                  Provider.of<UserModel>(context, listen: false)
                                      .email)
                              .collection("matjip")
                              .doc("bookmark")
                              .update({
                            i: FieldValue.arrayUnion(
                                [MatJip().toJson(widget.matjip!)])
                          });

                          Provider.of<UserModel>(context, listen: false)
                              .addMatJipList(widget.matjip!, i);

                          Get.back();

                          Get.snackbar("Success", "등록되었습니다");
                        },
                        child: const Text("등록하기"))
                  ],
                ));
              },
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                      onPressed: () {
                        List<String> bookmarkTitle = [];
                        for (var i in widget.bookmark?.keys ?? {""}) {
                          bookmarkTitle.add(i);
                        }
                        Get.bottomSheet(SizedBox(
                            height: (MediaQuery.of(context).size.height) / 3,
                            child: RegisterBookMark(
                              bookmarkTitle: bookmarkTitle,
                            ))).then((value) => () async {
                              var snap = await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(Provider.of<UserModel>(context,
                                          listen: false)
                                      .email)
                                  .collection("matjip")
                                  .doc("bookmark")
                                  .get();
                              var result = snap.data();

                              List<MatJip> temp = [];
                              Map<String, List<MatJip>> tempbookmark = {};

                              if (result?.isNotEmpty ?? false) {
                                for (var i in result?.keys ?? {"", ""}) {
                                  for (var j = 0; j < result?[i].length; j++) {
                                    temp.add(MatJip.fromJson(result?[i][j]));
                                  }
                                  widget.bookmark?[i] = temp;
                                  temp = [];
                                }
                              }
                              // widget.bookmark = conv;
                              setState(() {});
                            });
                      },
                      child: const Text("새로 추가하기")),
                ],
              ),
            ],
          )
        ],
      ),
    ));
  }
}
