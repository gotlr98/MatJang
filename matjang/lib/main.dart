import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'pages/Library5AddressToCoordsScreen.dart';
import 'pages/mapTest.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  AuthRepository.initialize(
      appKey: dotenv.env["APP_KEY"]!, baseUrl: dotenv.env["BASE_URL"]!);
  runApp(const MyApp());
}

// 지도 초기화하기

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Library5AddressToCoordsScreen());
  }
}
