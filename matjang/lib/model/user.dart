enum SocialType { Kakao, Apple, Guest }

class User {
  String? email;
  SocialType type = SocialType.Guest;

  User({
    this.email,
    required this.type,
  });
}
