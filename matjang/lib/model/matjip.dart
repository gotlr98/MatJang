import 'dart:convert';

class MatJip {
  String? place_name = "";
  String? x = "";
  String? y = "";

  MatJip({
    this.place_name,
    this.x,
    this.y,
  });

  factory MatJip.fromJson(Map<String, dynamic> json) {
    return MatJip(
      place_name: json["place_name"],
      x: json['x'],
      y: json['y'],
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
