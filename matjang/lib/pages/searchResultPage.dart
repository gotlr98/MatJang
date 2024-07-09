import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../model/matjip.dart';

class SearchResultPage extends StatefulWidget {
  SearchResultPage({super.key, this.matjip_list});
  List<MatJip>? matjip_list;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
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

                            var result =
                                await coold2Address(LatLng(37.5571, 127.0051));

                            Get.toNamed("/searchDirectionPage", arguments: {
                              "from": result,
                              "fromLat": LatLng(
                                  37.4826364, 126.501144), // 나중에 position으로 변경
                              "toLat": LatLng(
                                  double.parse(widget.matjip_list?[i].y ?? ""),
                                  double.parse(widget.matjip_list?[i].x ?? ""))
                            });
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
