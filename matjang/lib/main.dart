import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:matjang/model/usermodel.dart';
import 'package:matjang/pages/findFollowersPage.dart';
import 'package:matjang/pages/searchResultPage.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/detailPage.dart';
import 'pages/login.dart';
import 'pages/mapTest.dart';
import 'pages/test.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");
  KakaoSdk.init(
      nativeAppKey: dotenv.env["NATIVE_APP_KEY"],
      javaScriptAppKey: dotenv.env["JAVA_APP_KEY"]);
  AuthRepository.initialize(
      appKey: dotenv.env["APP_KEY"]!, baseUrl: dotenv.env["BASE_URL"]!);
  runApp(
    const MyApp(),
  );
}

// 지도 초기화하기

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserModel(type: SocialType.Guest),
      child: GetMaterialApp(
        home: const Login(),
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Login()),
          GetPage(name: '/test', page: () => const Test()),
          GetPage(name: '/mapTest', page: () => const MapTest()),
          GetPage(name: '/searchResultPage', page: () => SearchResultPage()),
          GetPage(name: '/detailPage', page: () => DetailPage()),
          GetPage(
              name: '/findFollowersPage',
              page: () => const FindFollowersPage()),
        ],
      ),
    );
  }
}
