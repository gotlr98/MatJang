import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:matjang/model/matjip.dart';
import 'package:matjang/pages/detailBottomSheet.dart';
import 'package:matjang/pages/detailPage.dart';
import 'package:matjang/pages/findFollowersPage.dart';
import 'package:matjang/pages/searchDirectionPage.dart';
import 'package:matjang/pages/searchResultPage.dart';
import 'package:matjang/pages/userOwnDetailPage.dart';
import 'package:provider/provider.dart';

import '../model/usermodel.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class viewModel with ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}

class _MainMapState extends State<MainMap> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late KakaoMapController mapController;
  TextEditingController searchField = TextEditingController();
  String message = "";
  String address2 = "";
  String request = "";
  String textContent = "";
  List<MatJip> matjipList = [];
  Set<Marker> markers = {};
  LatLng center = LatLng(37.572389, 126.9769117);
  var result = [];
  List<MatJip> temp = [];
  Map<String, List<MatJip>> myMatjipList = {};
  List<String> findAllUser = [];
  int mapLevel = 4;
  Map<String, Map<String, double>> get_matjip_review = {};
  final selectList = ["지도 둘러보기", "맛집 찾기"];
  var selectedValue = "맛집 찾기";
  List<String> following = [];
  List<String> follower = [];
  String user_email = "";
  bool isGuest = false;
  LatLng myLocation = LatLng(0, 0);
  List<MatJip> tempConv = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user_email = Get.arguments["email"];
      if (Provider.of<UserModel>(context, listen: false).getSocialType() ==
          "guest") {
        isGuest = true;
      }
      await _getUsersFollowing(Get.arguments["email"]);
      await _getUsersFollower(Get.arguments["email"]);
      await _getUsersMatjip();
      await _getUserMatjipsReview();
      await _getUserBlockList();
    });
    setState(() {});
  }

  _getUserBlockList() async {
    var snap = await FirebaseFirestore.instance.collection("users").get();

    var result = snap.docs;
    List<String> block = [];
    for (var i in result) {
      if (i.id == user_email) {
        var getBlockList = List<String>.from(i.data()["block"]);
        for (var j in getBlockList) {
          block.add(j);
        }
      }
      Provider.of<UserModel>(context, listen: false)
          .getBlockListFromFirebase(block);
    }
  }

  _getUsersFollowing(String email) async {
    var snap = await FirebaseFirestore.instance.collection("users").get();

    var result = snap.docs;
    following = [];
    for (var i in result) {
      if (i.id == email) {
        var getFollowing = List<String>.from(i.data()["following"]);
        for (var i in getFollowing) {
          following.add(i);
        }

        Provider.of<UserModel>(context, listen: false)
            .getFollowingFromFirebase(getFollowing);
      }
    }
  }

  _getUsersFollower(String email) async {
    var snap = await FirebaseFirestore.instance.collection("users").get();

    var result = snap.docs;
    follower = [];
    for (var i in result) {
      if (i.id == email) {
        var getFollower = List<String>.from(i.data()["follower"]);
        for (var i in getFollower) {
          follower.add(i);
        }

        Provider.of<UserModel>(context, listen: false)
            .getFollowerFromFirebase(getFollower);
      }
    }
  }

  _getUsersMatjip() async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user_email)
        .collection("matjip")
        .doc("bookmark")
        .get();

    var result = snap.data();
    myMatjipList = {};

    if (result != null) {
      for (var i in result.keys) {
        for (var j = 0; j < result[i].length; j++) {
          var tem = MatJip.fromDatabase(result[i][j]);
          tempConv.add(tem);
        }
        myMatjipList[i] = tempConv;
        tempConv = [];
      }
      Provider.of<UserModel>(context, listen: false)
          .getListFromFirebase(myMatjipList);
    }
    // matjipList = myMatjipList;
  }

  _getAllUsersMatjip() async {
    _getUsersFollowing(user_email);
    var snap = await FirebaseFirestore.instance.collection("users").get();

    var result = snap.docs;
    findAllUser = [];
    for (var i in result) {
      if (i.id != user_email &&
          !following.contains(i.id) &&
          !Provider.of<UserModel>(context, listen: false)
              .block_list
              .contains(i.id)) {
        findAllUser.add(i.id);
        temp = [];
      }
    }
  }

  _getUserMatjipsReview() async {
    var snap = await FirebaseFirestore.instance.collection("users").get();

    var result = snap.docs;

    for (var i in result) {
      if (i.id == user_email) {
        var getReview = i.data()["review"];
        if (getReview != null) {
          for (var i in getReview.keys) {
            Map<String, double> temp = {};
            String rev = getReview[i]
                .keys
                .toString()
                .replaceAll("(", "")
                .replaceAll(")", "");
            double rat = double.parse(getReview[i]
                .values
                .toString()
                .replaceAll("(", "")
                .replaceAll(")", ""));

            temp[rev] = rat;
            get_matjip_review[i] = temp;
          }
        }

        if (get_matjip_review.isNotEmpty) {
          Provider.of<UserModel>(context, listen: false)
              .getReviewFromFirebase(get_matjip_review);
        }
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

  coord2Keyword(String keyword, LatLng lng) async {
    bool isEnd = false;
    int page = 1;

    while (isEnd = true) {
      var url =
          "https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword&page=$page";

      var header = {"Authorization": "KakaoAK ${dotenv.env["REST_API_KEY"]}"};
      var response = await http.get(Uri.parse(url), headers: header);
      var check = jsonDecode(response.body);
      if (response.statusCode == 200) {
        matjipList += MatJip().matjipDatasFromJson(response.body);
      } else {
        break;
      }
      if (check["meta"]["is_end"] == true) {
        isEnd = true;

        break;
      }

      isEnd = true;
      page += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    String nickName =
        (Provider.of<UserModel>(context, listen: false).email ?? "")
            .split("@")[0];
    return Scaffold(
      key: scaffoldKey,
      onDrawerChanged: (isOpened) {
        setState(() async {
          if (isOpened == true) {
            await _getUsersMatjip();
            await _getUserBlockList();
            await _getUsersFollower(user_email);
            await _getUsersFollowing(user_email);
          }
        });
      },
      appBar: AppBar(
        title: const Text(
          "맛짱",
          style: TextStyle(letterSpacing: 3.0, fontSize: 18),
        ),
        actions: [
          DropdownButton(
            value: selectedValue,
            items: selectList.map(
              (value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            onChanged: (value) {
              setState(() {
                selectedValue = value ?? "";
                if (selectedValue == "지도 둘러보기") {
                  matjipList = [];
                  markers.clear();
                }
              });
            },
          )
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
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
                    "$nickName 님 \nfollower ${follower.length}명    following ${following.length}명",
                    style: const TextStyle(color: Colors.black)),
                // onDetailsPressed: () {},
                currentAccountPicture: InkWell(
                    onTap: () async {
                      await _getUserMatjipsReview();
                      await _getUsersFollowing(user_email);
                      Get.to(() => UserOwnDetailPage(
                            review: get_matjip_review,
                            following: following,
                          ));
                    },
                    child: const Icon(Icons.people)),
                currentAccountPictureSize: const Size.square(20),
                otherAccountsPictures: [
                  InkWell(
                      onTap: () async {
                        if (scaffoldKey.currentState!.isDrawerOpen) {
                          scaffoldKey.currentState!.closeDrawer();
                        }
                        await _getAllUsersMatjip();

                        Get.to(() => FindFollowersPage(
                            findAllUser: findAllUser, isGuest: isGuest));
                      },
                      child: Image.asset("assets/images/followers.png")),
                ],
                otherAccountsPicturesSize: const Size.square(20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "내 맛집 리스트",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                      onPressed: () {
                        mapLevel = 6;
                        markers.clear();
                        for (var i in myMatjipList.keys) {
                          for (var j in myMatjipList[i]!) {
                            markers.add(Marker(
                                markerId: UniqueKey().toString(),
                                latLng: LatLng(double.parse(j.y ?? ""),
                                    double.parse(j.x ?? ""))));
                          }
                        }
                        if (scaffoldKey.currentState!.isDrawerOpen) {
                          scaffoldKey.currentState!.closeDrawer();
                        }
                        selectedValue = "지도 둘러보기";
                        mapController.setLevel(mapLevel);

                        setState(() {});
                      },
                      icon: const Icon(Icons.map))
                ],
              ),
              SingleChildScrollView(
                child: Column(children: [
                  for (var i in myMatjipList.keys) ...[
                    ExpansionTile(
                      title: Text(i),
                      children: [
                        for (var j in myMatjipList[i] ?? []) ...[
                          ListTile(
                            title: Text(
                              j.place_name ?? "",
                              style: const TextStyle(fontSize: 12),
                            ),
                            leading: const Icon(Icons.food_bank),
                            onTap: () {
                              var count = 0;
                              matjipList = [];
                              markers.clear();
                              matjipList.add(j);
                              markers.add(Marker(
                                markerId: UniqueKey().toString(),
                                latLng: LatLng(double.parse(j.y ?? ""),
                                    double.parse(j.x ?? "")),
                              ));
                              if (count == 0) {
                                center = LatLng(double.parse(j.y ?? ""),
                                    double.parse(j.x ?? ""));
                                count += 1;
                              }

                              mapController.setCenter(center);
                              setState(() {});

                              if (scaffoldKey.currentState!.isDrawerOpen) {
                                scaffoldKey.currentState!.closeDrawer();
                              }
                            },
                          )
                        ]
                      ],
                    ),
                  ],
                ]),
              )
            ],
          ),
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
          onMarkerTap: (markerId, latLng, zoomLevel) async {
            String? address;
            String? placeName;
            String? categoryName;
            String? x;
            String? y;
            bool isRegister = false;
            bool isReviewed = false;
            Marker marker = Marker(
                markerId: "0",
                latLng: LatLng(latLng.latitude, latLng.longitude));
            Map<String, Map<String, double>> matjipReview = {};

            // matjipList =
            //     Provider.of<UserModel>(context, listen: false).matjipList;
            for (var i in markers) {
              if (i.markerId == "currentMarker") {
                return;
              }
              if (markerId == i.markerId) {
                marker = i;
              }
            }

            for (var i in matjipList) {
              if (double.parse(i.x ?? "") == marker.latLng.longitude &&
                  double.parse(i.y ?? "") == marker.latLng.latitude) {
                address = i.address;
                placeName = i.place_name;
                categoryName = i.category?.split(">").last;
                x = i.x;
                y = i.y;
              }
            }

            var temp =
                await FirebaseFirestore.instance.collection("matjips").get();
            var matjipReviewGet = temp.docs;

            for (var i in matjipReviewGet) {
              if (i.id == "$placeName&$address") {
                for (var j in i.data().keys) {
                  if (j != user_email &&
                      !Provider.of<UserModel>(context, listen: false)
                          .block_list
                          .contains(j)) {
                    matjipReview[j] = Map<String, double>.from(i.data()[j]);
                  }
                }
              }
            }

            var checkRegister =
                Provider.of<UserModel>(context, listen: false).matjipList;
            Map<String, bool> checkBookmarkRegister = {};
            for (var i in checkRegister.keys) {
              for (var j in checkRegister[i] ?? []) {
                if (j.address == address) {
                  checkBookmarkRegister[i] = true;
                  isRegister = true;
                }
              }
            }

            var checkReview =
                Provider.of<UserModel>(context, listen: false).review;

            for (var i in checkReview.keys) {
              if (i == "$placeName&$address") {
                isReviewed = true;
              }
            }

            if (address != null && placeName != null) {
              Get.bottomSheet(GestureDetector(
                onTap: () {
                  if (get_matjip_review.isEmpty) {
                    Get.to(
                        () => DetailPage(
                            address: address,
                            place_name: placeName,
                            isRegister: isRegister,
                            isReviewed: isReviewed,
                            category: categoryName,
                            review: const {},
                            matjipReview: matjipReview,
                            isGuest: isGuest),
                        transition: Transition.circularReveal);
                  } else {
                    for (var i in get_matjip_review.keys) {
                      var reviews = get_matjip_review[i];
                      Get.to(
                          () => DetailPage(
                              address: address,
                              place_name: placeName,
                              isRegister: isRegister,
                              isReviewed: isReviewed,
                              category: categoryName,
                              review: reviews,
                              matjipReview: matjipReview,
                              isGuest: isGuest),
                          transition: Transition.cupertino);
                    }
                  }
                },
                child: SizedBox(
                  height: 200,
                  child: DetailBottomSheet(
                    address: address,
                    place_name: placeName,
                    category: categoryName,
                    x: x,
                    y: y,
                    isRegister: isRegister,
                    isGuest: isGuest,
                    checkBookmarkRegister: checkBookmarkRegister,
                  ),
                ),
              ));
            }
            // else if(){

            // }
            else {
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
            if (selectedValue == "맛집 찾기") {
              if (dragType == DragType.end) {
                matjipList = [];
                markers.clear();
                await coord2Category(latLng);

                for (var i in matjipList) {
                  markers.add(Marker(
                    markerId: UniqueKey().toString(),
                    latLng: LatLng(
                        double.parse(i.y ?? ""), double.parse(i.x ?? "")),
                    // infoWindowContent: i.place_name!,
                  ));
                }

                setState(() {});
              }
            }
          },
          currentLevel: mapLevel,
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
                    var cen = await mapController.getCenter();
                    await coord2Keyword(searchField.text, cen);

                    if (searchField.text.isEmpty) {
                      Get.snackbar("실패", "검색어를 입력해주세요");
                      return;
                    }

                    if (matjipList.isEmpty) {
                      Get.snackbar("실패", "검색 결과가 없습니다");
                      return;
                    }
                    for (var i in matjipList) {
                      markers.add(Marker(
                        markerId: UniqueKey().toString(),
                        latLng: LatLng(
                            double.parse(i.y ?? ""), double.parse(i.x ?? "")),
                      ));
                      if (count == 0) {
                        center = LatLng(
                            double.parse(i.y ?? ""), double.parse(i.x ?? ""));
                        count += 1;
                      }
                    }

                    mapController.setCenter(center);

                    searchField.clear();

                    selectedValue = "지도 둘러보기";

                    Get.bottomSheet(ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: (4 / 5) *
                                    MediaQuery.of(context).size.height),
                            child: SearchResultPage(matjip_list: matjipList)))
                        .then((value) {
                      center = LatLng(double.parse(value["touch_result"].y),
                          double.parse(value["touch_result"].x));
                      mapController.setCenter(center);

                      setState(() {});
                    });

                    setState(() {});
                  },
                  child: const Icon(Icons.search)),
              const SizedBox(width: 10),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white),
                  child: IconButton(
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

                            setState(() {
                              myLocation =
                                  LatLng(position.latitude, position.longitude);

                              markers.add(Marker(
                                  markerId: "currentMarker",
                                  latLng: LatLng(
                                      position.latitude, position.longitude),
                                  markerImageSrc:
                                      "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbB7t3J%2Fbtr0KRodrrM%2FBB4jmkjt9eYbdiKAySATnK%2Fimg.png"));

                              mapController.setCenter(myLocation);
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.my_location_rounded)),
                ),
                const SizedBox(
                  height: 240,
                )
              ],
            ),
          ],
        )
      ]),
    );
  }
}
