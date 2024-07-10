import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:matjang/pages/searchDirectionPage.dart';
import '../model/matjip.dart';

class SearchResultPage extends StatefulWidget {
  SearchResultPage({super.key, this.matjip_list});
  List<MatJip>? matjip_list;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List<Polyline> polylines = [];
  List<LatLng> polyline = [];
  Future<String> coold2Address(LatLng lng) async {
    var url =
        "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=${lng.longitude}&y=${lng.latitude}";

    var header = {"Authorization": "KakaoAK ${dotenv.env["REST_API_KEY"]}"};
    var response = await http.get(Uri.parse(url), headers: header);

    if (response.statusCode == 200) {
      var temp = jsonDecode(response.body);
      if (temp["documents"][0]["road_address"] != null) {
        return temp["documents"][0]["road_address"];
      } else if (temp["documents"][0] != null &&
          temp["documents"][0]["address"]["address_name"] != null) {
        return temp["documents"][0]["address"]["address_name"];
      } else {
        return "error";
      }
    } else {
      return "error";
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

  Future<String> searchDirection(LatLng from, LatLng to) async {
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

        return convSeconds(duration);
      } else {
        return "error";
      }
    } else {
      print(response.statusCode);
      return "error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          for (int i = 0; i < (widget.matjip_list?.length ?? 0); i++) ...[
            InkWell(
              onTap: () {
                Get.back(result: {"touch_result": widget.matjip_list?[i]});
              },
              child: Card(
                child: ListTile(
                  title: Text(widget.matjip_list?[i].place_name ?? ""),
                  subtitle: Text(widget.matjip_list?[i].address ?? ""),
                  trailing: ElevatedButton(
                      onPressed: () async {
                        bool serviceEnabled =
                            await Geolocator.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          return Future.error(
                              'Location services are disabled.');
                        } else {
                          LocationPermission permission =
                              await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                            if (permission == LocationPermission.denied) {
                              return Future.error('permissions are denied');
                            }
                          } else {
                            Position position =
                                await Geolocator.getCurrentPosition();

                            // coold2Address(
                            //     LatLng(position.latitude, position.longitude));

                            // var result =
                            //     await coold2Address(LatLng(37.5571, 127.0051));

                            // Get.toNamed("/searchDirectionPage", arguments: {
                            //   "from": result,
                            //   "fromLat": LatLng(
                            //       37.4826364, 126.501144), // 나중에 position으로 변경
                            //   "toLat": LatLng(
                            //       double.parse(widget.matjip_list?[i].y ?? ""),
                            //       double.parse(widget.matjip_list?[i].x ?? ""))
                            // });

                            // await searchDirection(
                            //     LatLng(position.latitude, position.longitude),
                            //     LatLng(
                            //         double.parse(
                            //             widget.matjip_list?[i].y ?? ""),
                            //         double.parse(
                            //             widget.matjip_list?[i].x ?? "")));

                            var duration = await searchDirection(
                                LatLng(37.4826364, 126.501144),
                                LatLng(
                                    double.parse(
                                        widget.matjip_list?[i].y ?? ""),
                                    double.parse(
                                        widget.matjip_list?[i].x ?? "")));
                            print("function done");
                            Get.to(() => SearchDirectionPage(
                                polylines: polylines, duration: duration));
                            setState(() {});
                          }
                        }
                      },
                      child: const Icon(Icons.directions)),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
