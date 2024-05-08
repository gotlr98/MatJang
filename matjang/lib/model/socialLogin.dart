import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:matjang/model/usermodel.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLogin {
  Future<UserModel?> socialLogin({
    required socialType,
  }) async {
    switch (socialType) {
      case SocialType.Apple:
        return _apple();
      case SocialType.Kakao:
        return _kakao();
      // case SocialType.Guest:
      //   return _guest();
    }
    return null;
  }

  Future<UserModel?> _kakao() async {
    bool isInstalled = await isKakaoTalkInstalled();
    var store = const FlutterSecureStorage();

    isInstalled
        ? await UserApi.instance.loginWithKakaoTalk()
        : await UserApi.instance.loginWithKakaoAccount();

    var user = await UserApi.instance.me();
    String? email = user.kakaoAccount?.email;

    await store.write(key: "login", value: email);

    print(store.readAll());

    return email != ''
        ? UserModel(email: email!, type: SocialType.Kakao)
        : null;
  }

  Future<UserModel?> _apple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    String? email = appleCredential.email;
    return email != ''
        ? UserModel(email: email!, type: SocialType.Apple)
        : null;
  }
}
