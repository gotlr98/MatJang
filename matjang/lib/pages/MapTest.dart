import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:matjang/model/matjip.dart';

class MapTest extends StatefulWidget {
  const MapTest({super.key});

  @override
  State<MapTest> createState() => _MapTestState();
}

class _MapTestState extends State<MapTest> {
  late KakaoMapController mapController;
  TextEditingController searchField = TextEditingController();
  String message = "";
  String address2 = "";
  String request = "";
  var matjipList;

  coord2Address(LatLng lng) async {
    var url =
        "https://dapi.kakao.com/v2/local/search/category.json?category_group_code=FD6&x=${lng.longitude}&y=${lng.latitude}&radius=1000";
    var header = {"Authorization": "KakaoAK ${dotenv.env["REST_API_KEY"]}"};

    var response = await http.get(Uri.parse(url), headers: header);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body)["documents"];

      matjipList = MatJipList.fromJson(result).matjips ?? <MatJip>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("맛장")),
      body: Stack(children: [
        KakaoMap(
          center: LatLng(37.4826364, 126.501144),
          onMapCreated: ((controller) async {
            mapController = controller;
            var center = await mapController.getCenter();

            // coord2Address(center);
          }),
          onMapTap: ((lag) async {
            await mapController.getCenter();
            // coord2Address(lag);
            setState(() {});
          }),
          onDragChangeCallback: (latLng, zoomLevel, dragType) async {
            if (dragType == DragType.end) {
              await coord2Address(latLng);

              print(matjipList);
            }
          },
          currentLevel: 4,
          zoomControl: true,
          zoomControlPosition: ControlPosition.bottomRight,
        ),
        Container(
          // width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            // borderRadius: BorderRadius.circular(2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                style: const TextStyle(fontSize: 20),
                controller: searchField,
                decoration: const InputDecoration(hintText: "검색어를 입력하세요"),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
