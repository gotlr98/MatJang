import 'dart:convert';

import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class MatJip {
  String? place_name = "";
  String? x = "";
  String? y = "";
  String? address = "";
  String? category = "";

  MatJip({
    this.place_name,
    this.x,
    this.y,
    this.address,
    this.category,
  });

  factory MatJip.fromJson(Map<String, dynamic> json) {
    return MatJip(
      place_name: json["place_name"],
      x: json['x'],
      y: json['y'],
      address: json['road_address_name'],
      category: json['category_name'],
    );
  }

  List<MatJip> matjipDatasFromJson(String json) {
    List<dynamic> parsedJson = jsonDecode(json)["documents"];
    List<MatJip> matjipdatas = [];
    for (int i = 0; i < parsedJson.length; i++) {
      matjipdatas.add(MatJip.fromJson(parsedJson[i]));
    }
    return matjipdatas;
  }
}

class MatJipList {
  final List<MatJip>? matjips;
  MatJipList({this.matjips});

  factory MatJipList.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);
    List<MatJip> matjips = <MatJip>[];

    matjips = listFromJson.map((place) => MatJip.fromJson(place)).toList();
    return MatJipList(matjips: matjips);
  }
}
