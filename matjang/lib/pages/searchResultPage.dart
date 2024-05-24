import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/matjip.dart';

class SearchResultPage extends StatelessWidget {
  SearchResultPage({super.key, this.matjip_list});
  List<MatJip>? matjip_list;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          for (int i = 0; i < matjip_list!.length; i++)
            InkWell(
              onTap: () {
                Get.back(result: {"touch_result": matjip_list![i]});
              },
              child: Card(
                child: ListTile(
                  title: Text(matjip_list![i].place_name!),
                  subtitle: Text(matjip_list![i].address!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
