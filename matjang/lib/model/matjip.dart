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

  factory MatJip.fromJson(Map<String, dynamic> json) => MatJip(
        place_name: json["place_name"],
        x: json['x'],
        y: json['y'],
      );
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
