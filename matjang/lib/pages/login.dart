import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:matjang/model/socialLogin.dart';

import '../model/usermodel.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  UserModel? user;
  static const storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    //read 함수를 통하여 key값에 맞는 정보를 불러오게 됩니다. 이때 불러오는 결과의 타입은 String 타입임을 기억해야 합니다.
    //(데이터가 없을때는 null을 반환을 합니다.)
    user?.email = await storage.read(key: "login");
    print(user?.email);

    //user의 정보가 있다면 바로 로그아웃 페이지로 넝어가게 합니다.
    if (user?.email != null) {
      Get.toNamed("/test");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () async {
                user = await SocialLogin()
                    .socialLogin(socialType: SocialType.Kakao);

                Get.toNamed("/test");
              },
              child:
                  Image.asset("assets/images/kakao_login_medium_narrow.png")),
        ],
      ),
    );
  }
}
