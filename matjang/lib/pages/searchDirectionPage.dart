import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:http/http.dart' as http;

class SearchDirectionPage extends StatefulWidget {
  SearchDirectionPage({super.key, this.polylines, this.duration});

  @override
  State<SearchDirectionPage> createState() => _SearchDirectionPageState();

  List<Polyline>? polylines = [];
  String? duration = "";
}

class _SearchDirectionPageState extends State<SearchDirectionPage> {
  late KakaoMapController mapController;
  LatLng center = LatLng(37.572389, 126.9769117);

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
        body: Stack(
          children: [
            KakaoMap(
              onMapCreated: ((controller) async {
                mapController = controller;
                var center = await mapController.getCenter();
                setState(() {});
                // coord2Address(center);
              }),
              polylines: widget.polylines!.toList(),
              currentLevel: 11,
              zoomControl: true,
              zoomControlPosition: ControlPosition.bottomRight,
              center: center,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.duration} 소요" ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
