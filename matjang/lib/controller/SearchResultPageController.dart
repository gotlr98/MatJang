import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class SearchResultPageController {
  List<LatLng> polyline = [];
  List<Polyline> polylines = [];
  String duration = "";

  convSeconds(int sec) {
    if (sec < 61) {
      duration = "$sec 초";
    } else if (sec < 3600) {
      var min = (sec / 60).floor();
      var second = sec - min * 60;
      duration = "${(min)}분 $second초";
    } else {
      var hour = (sec / 3600).floor();
      var min = ((sec - hour * 3600) / 60).floor();
      var second = sec - hour * 3600 - min * 60;
      duration = "$hour시간 $min분 $second초";
    }
  }

  searchDirection(LatLng from, LatLng to) async {
    var url =
        "https://apis-navi.kakaomobility.com/v1/directions?origin=${from.longitude},${from.latitude}&destination=${to.longitude},${to.latitude}";
    var header = {"Authorization": "KakaoAK ${dotenv.env["REST_API_KEY"]}"};
    var response = await http.get(Uri.parse(url), headers: header);

    if (response.statusCode == 200) {
      var temp = jsonDecode(response.body);
      var duration = temp["routes"][0]["summary"]["duration"];

      if (temp["routes"][0]["result_msg"] == "길찾기 성공") {
        var roads = temp["routes"][0]["sections"][0]["roads"];
        for (var i in roads) {
          for (int j = 0; j < i.length - 2; j++) {
            if (j % 2 == 0) {
              polyline.add(LatLng(i["vertexes"][j + 1], i["vertexes"][j]));
            }
          }
        }
        polylines.add(Polyline(
            polylineId: "polyLine ${polyline.length}",
            points: polyline,
            strokeWidth: 12,
            strokeColor: Colors.black,
            strokeStyle: StrokeStyle.solid));

        convSeconds(duration);
      } else {
        return "error";
      }
    } else {
      print(response.statusCode);
      return "error";
    }
  }
}
