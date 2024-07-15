import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../model/matjip.dart';
import '../model/usermodel.dart';

class MainMapController extends ChangeNotifier {
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

  _getUserBlockList(BuildContext context) async {
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

  _getUsersFollowing(String email, BuildContext context) async {
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

  _getUsersFollower(String email, BuildContext context) async {
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

  _getUsersMatjip(BuildContext context) async {
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

  _getAllUsersMatjip(BuildContext context) async {
    _getUsersFollowing(user_email, context);
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

  _getUserMatjipsReview(BuildContext context) async {
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
}
