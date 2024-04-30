import 'matjip.dart';

enum SocialType { Kakao, Apple, Guest }

class UserModel {
  String? email;
  SocialType type = SocialType.Guest;
  List<MatJip> matjipList = [];

  UserModel({
    this.email,
    required this.type,
  });
}
