import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:matjang/pages/searchDirectionPage.dart';
import '../controller/SearchResultPageController.dart';
import '../model/matjip.dart';

class SearchResultPage extends StatefulWidget {
  SearchResultPage({super.key, this.matjip_list});
  List<MatJip>? matjip_list;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  @override
  Widget build(BuildContext context) {
    SearchResultPageController search = SearchResultPageController();
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

                            await search.searchDirection(
                                LatLng(37.4826364, 126.501144),
                                LatLng(
                                    double.parse(
                                        widget.matjip_list?[i].y ?? ""),
                                    double.parse(
                                        widget.matjip_list?[i].x ?? "")));
                            Get.to(() => SearchDirectionPage(
                                polylines: search.polylines,
                                duration: search.duration));
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
