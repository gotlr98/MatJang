import 'package:flutter/material.dart';

import 'matjip.dart';

enum SocialType { Kakao, Apple, Guest }

class UserModel with ChangeNotifier {
  String? email;
  SocialType type = SocialType.Guest;
  List<MatJip> matjipList = [];
  List<MatJip> get _matjipList => matjipList;
  String? get _email => email;
  SocialType get _type => type;
  Map<String, String> review = {};
  Map<String, String> get _review => review;

  UserModel({
    this.email,
    required this.type,
  });

  void addList(MatJip matjip) {
    matjipList.add(matjip);
    notifyListeners();
  }

  void getListFromFirebase(List<MatJip> matjipList) {
    this.matjipList = matjipList;
    notifyListeners();
  }

  void setEmailAndType(String email, SocialType type) {
    this.email = email;
    this.type = type;
    notifyListeners();
  }

  void addReview(String placeName, String review) {
    this.review[placeName] = review;
    notifyListeners();
  }

  void getReviewFromFirebase(Map<String, String> reviews) {
    review = reviews;
    notifyListeners();
  }
}
