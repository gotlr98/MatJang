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
  Map<String, Map<String, double>> review = {};
  Map<String, Map<String, double>> get _review => review;
  List<String> following = [];
  List<String> get _following => following;
  List<String> follower = [];
  List<String> get _follower => follower;

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

  void addReview(String placeName, Map<String, double> review) {
    this.review[placeName] = review;
    notifyListeners();
  }

  void getReviewFromFirebase(Map<String, Map<String, double>> reviews) {
    review = reviews;
    notifyListeners();
  }

  void getFollowingFromFirebase(List<String> following) {
    this.following = following;
    notifyListeners();
  }

  void addFollowing(String email) {
    following.add(email);
    notifyListeners();
  }

  void getFollowerFromFirebase(List<String> follower) {
    this.follower = follower;
    notifyListeners();
  }
}
