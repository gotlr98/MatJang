import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class InitLodingPage extends StatefulWidget {
  const InitLodingPage({super.key});

  @override
  State<InitLodingPage> createState() => _InitLodingPageState();
}

class _InitLodingPageState extends State<InitLodingPage>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset("assets/json/MatjipAnimation.json",
            controller: controller, onLoaded: (composition) {
          controller.duration = composition.duration;
          controller.forward().whenComplete(() => Get.toNamed("/login"));
        }),
      ),
    );
  }
}
