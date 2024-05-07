import 'package:flutter/material.dart';
import 'package:matjang/model/socialLogin.dart';

import '../model/usermodel.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                SocialLogin().socialLogin(socialType: SocialType.Kakao);
              },
              child:
                  Image.asset("assets/images/kakao_login_medium_narrow.png")),
        ],
      ),
    );
  }
}
