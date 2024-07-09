import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:http/http.dart' as http;

class SearchDirectionPage extends StatefulWidget {
  const SearchDirectionPage({super.key});

  @override
  State<SearchDirectionPage> createState() => _SearchDirectionPageState();
}

class _SearchDirectionPageState extends State<SearchDirectionPage> {
  TextEditingController fromText =
      TextEditingController(text: Get.arguments["from"]);
  TextEditingController toText = TextEditingController();

  searchDirection() async {
    var url =
        "https://apis-navi.kakaomobility.com/v1/directions?origin=${Get.arguments["fromLat"].longitude},${Get.arguments["fromLat"].latitude}&destination=${Get.arguments["toLat"].longitude},${Get.arguments["toLat"].latitude}";
    var header = {"Authorization": "KakaoAK ${dotenv.env["REST_API_KEY"]}"};
    var response = await http.get(Uri.parse(url), headers: header);

    if (response.statusCode == 200) {
      var temp = jsonDecode(response.body);
      var duration = temp["routes"][0]["summary"]["duration"];
      print(duration);

      print(convSeconds(4000));
    } else {
      print(response.statusCode);
    }
  }

  String convSeconds(int sec) {
    if (sec < 61) {
      return "$sec 초";
    } else if (sec < 3600) {
      var min = (sec / 60).floor();
      var second = sec - min * 60;
      return "${(min)}분 $second초";
    } else {
      var hour = (sec / 3600).floor();
      var min = ((sec - hour * 3600) / 60).floor();
      var second = sec - hour * 3600 - min * 60;
      return "$hour시간 $min분 $second초";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.cancel_outlined))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextField(controller: fromText),
          TextField(controller: toText),
          ElevatedButton(
              onPressed: () => searchDirection(),
              child: const Icon(Icons.search))
        ],
      ),
    );
  }
}
