import 'package:matjang/model/User.dart';

class SocialLogin {
  Future<Result<UserModel?, CustomException>> socialLogin({
    required socialType,
  }) async {
    switch (socialType) {
      case SocialType.Apple:
        return _apple();
      case SocialType.Kakao:
        return _kakao();
      case SocialType.Guest:
        return _guest();
    }
  }
}
