import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:matjang/model/matjip.dart';
import 'package:matjang/pages/detailBottomSheet.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class MapTest extends StatefulWidget {
  const MapTest({super.key});

  @override
  State<MapTest> createState() => _MapTestState();
}

class _MapTestState extends State<MapTest> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late KakaoMapController mapController;
  TextEditingController searchField = TextEditingController();
  String message = "";
  String address2 = "";
  String request = "";
  String textContent = "";
  List<MatJip> matjipList = [];
  Set<Marker> markers = {};
  LatLng center = LatLng(37.4826364, 126.501144);
  var result = [];
  List<MatJip> myMatjipList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    var snap = await FirebaseFirestore.instance.collection("users").get();

    var result = snap.docs;

    for (var i in result) {
      myMatjipList = [];
      if (i.id == Get.arguments["email"]) {
        var getMatjip = i.data()["matjip"];

        this.result.add(getMatjip);
        for (var i in getMatjip) {
          // matjipList.add(i);
          myMatjipList.add(MatJip(
              place_name: i["place_name"],
              x: i["x"],
              y: i["y"],
              address: i["address"],
              category: i["category"]));
        }
        Provider.of<UserModel>(context, listen: false)
            .getListFromFirebase(myMatjipList);
      }
    }
  }

  coord2Category(LatLng lng) async {
    var url =
        "https://dapi.kakao.com/v2/local/search/category.json?category_group_code=FD6&x=${lng.longitude}&y=${lng.latitude}&radius=1000";
    var header = {"Authorization": "KakaoAK ${dotenv.env["REST_API_KEY"]}"};

    var response = await http.get(Uri.parse(url), headers: header);
    if (response.statusCode == 200) {
      matjipList = MatJip().matjipDatasFromJson(response.body);
    }
  }

  coord2Keyword(String keyword) async {
    var url =
        "https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword";

    var header = {"Authorization": "KakaoAK ${dotenv.env["REST_API_KEY"]}"};
    var response = await http.get(Uri.parse(url), headers: header);
    if (response.statusCode == 200) {
      matjipList = MatJip().matjipDatasFromJson(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      onDrawerChanged: (isOpened) {
        setState(() {
          _asyncMethod();
        });
      },
      appBar: AppBar(
        title: const Text("맛장"),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0)),
                ),
                accountName:
                    const Text("Hi", style: TextStyle(color: Colors.black)),
                accountEmail: Text(
                    Provider.of<UserModel>(context, listen: false).email!,
                    style: const TextStyle(color: Colors.black))),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "내 맛집 리스트",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: myMatjipList.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(myMatjipList[i].place_name!),
                  onTap: () {
                    var count = 0;
                    matjipList = [];
                    markers.clear();

                    matjipList.add(myMatjipList[i]);
                    markers.add(Marker(
                      markerId: UniqueKey().toString(),
                      latLng: LatLng(double.parse(myMatjipList[i].y!),
                          double.parse(myMatjipList[i].x!)),
                      infoWindowContent: myMatjipList[i].place_name!,
                    ));
                    if (count == 0) {
                      center = LatLng(double.parse(myMatjipList[i].y!),
                          double.parse(myMatjipList[i].x!));
                      count += 1;
                    }

                    mapController.setCenter(center);

                    if (scaffoldKey.currentState!.isDrawerOpen) {
                      scaffoldKey.currentState!.closeDrawer();
                    }
                    setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(children: [
        KakaoMap(
          center: center,
          onMapCreated: ((controller) async {
            mapController = controller;
            var center = await mapController.getCenter();

            // coord2Address(center);
          }),
          onMapTap: ((lag) async {
            await mapController.getCenter();
            setState(() {});
          }),
          onMarkerTap: (markerId, latLng, zoomLevel) {
            String? address;
            String? placeName;
            String? categoryName;
            String? x;
            String? y;
            bool isRegister = false;
            Marker marker = Marker(
                markerId: "0",
                latLng: LatLng(latLng.latitude, latLng.longitude));
            for (var i in markers) {
              if (markerId == i.markerId) {
                marker = i;
              }
            }
            if (matjipList.isEmpty) {
              for (var i in myMatjipList) {
                if (double.parse(i.x!) == marker.latLng.longitude &&
                    double.parse(i.y!) == marker.latLng.latitude) {
                  address = i.address;
                  placeName = i.place_name;
                  categoryName = i.category?.split(">").last;
                  x = i.x;
                  y = i.y;
                }
              }
            } else {
              for (var i in matjipList) {
                if (double.parse(i.x!) == marker.latLng.longitude &&
                    double.parse(i.y!) == marker.latLng.latitude) {
                  address = i.address;
                  placeName = i.place_name;
                  categoryName = i.category?.split(">").last;
                  x = i.x;
                  y = i.y;
                }
              }
            }
            var check =
                Provider.of<UserModel>(context, listen: false).matjipList;
            for (var i in check) {
              if (i.address == address) {
                isRegister = true;
              }
            }

            if (address != null && placeName != null) {
              Get.bottomSheet(SizedBox(
                height: 200,
                child: DetailBottomSheet(
                  address: address,
                  place_name: placeName,
                  category: categoryName,
                  x: x,
                  y: y,
                  isRegister: isRegister,
                ),
              ));
            } else {
              Get.dialog(
                AlertDialog(
                  title: const Text('Error'),
                  content: const Text('dialog content'),
                  actions: [
                    TextButton(
                      onPressed: Get.back,
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              );
            }
          },
          onDragChangeCallback: (latLng, zoomLevel, dragType) async {
            if (dragType == DragType.end) {
              matjipList = [];
              markers.clear();
              await coord2Category(latLng);

              for (var i in matjipList) {
                markers.add(Marker(
                  markerId: UniqueKey().toString(),
                  latLng: LatLng(double.parse(i.y!), double.parse(i.x!)),
                  // infoWindowContent: i.place_name!,
                ));
              }

              setState(() {});
            }
          },
          currentLevel: 4,
          zoomControl: true,
          zoomControlPosition: ControlPosition.bottomRight,
          markers: markers.toList(),
        ),
        Container(
          // width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            // borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  controller: searchField,
                  decoration: const InputDecoration(hintText: "검색어를 입력하세요"),
                  onChanged: (value) {
                    setState(() {
                      textContent = searchField.text;
                    });
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    var count = 0;
                    matjipList = [];
                    markers.clear();
                    await coord2Keyword(searchField.text);

                    for (var i in matjipList) {
                      markers.add(Marker(
                        markerId: UniqueKey().toString(),
                        latLng: LatLng(double.parse(i.y!), double.parse(i.x!)),
                        infoWindowContent: i.place_name!,
                      ));
                      if (count == 0) {
                        center = LatLng(double.parse(i.y!), double.parse(i.x!));
                        count += 1;
                      }
                    }

                    mapController.setCenter(center);

                    searchField.clear();

                    setState(() {});
                  },
                  child: const Icon(Icons.search))
            ],
          ),
        ),
      ]),
    );
  }
}
