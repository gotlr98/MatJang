import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matjang/pages/registerBookmark.dart';
import 'package:provider/provider.dart';

import '../model/matjip.dart';
import '../model/usermodel.dart';

class BookmarkBottomsheet extends StatefulWidget {
  BookmarkBottomsheet({super.key, this.bookmark});

  @override
  State<BookmarkBottomsheet> createState() => _BookmarkBottomsheetState();

  List<Map<String, List<MatJip>>>? bookmark;
}

class _BookmarkBottomsheetState extends State<BookmarkBottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < (widget.bookmark?.length ?? 0); i++)
          for (var j in widget.bookmark?[i].keys ?? {"", ""}) ...[
            ListTile(
              title: Text(j),
              subtitle:
                  Text("${widget.bookmark?[i].length.toString()}개" ?? "null"),
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
                      Get.bottomSheet(SizedBox(
                              height: (MediaQuery.of(context).size.height) / 3,
                              child: const RegisterBookMark()))
                          .then((value) => () async {
                                var snap = await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(Provider.of<UserModel>(context,
                                            listen: false)
                                        .email)
                                    .collection("bookmark")
                                    .get();
                                var result = snap.docs;

                                Map<String, List<MatJip>> conv = {};
                                for (var i in result) {
                                  if (i.id ==
                                      Provider.of<UserModel>(context,
                                              listen: false)
                                          .email) {
                                    var temp = i.data()["matjip"];
                                    for (var j in temp.keys) {
                                      conv[j] = temp[j];
                                    }
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
    ));
  }
}
