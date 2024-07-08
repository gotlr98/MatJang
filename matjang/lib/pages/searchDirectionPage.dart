import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchDirectionPage extends StatefulWidget {
  const SearchDirectionPage({super.key});

  @override
  State<SearchDirectionPage> createState() => _SearchDirectionPageState();
}

class _SearchDirectionPageState extends State<SearchDirectionPage> {
  TextEditingController fromText =
      TextEditingController(text: Get.arguments["from"]);
  TextEditingController toText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.cancel_outlined))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextField(controller: fromText),
          TextField(controller: toText)
        ],
      ),
    );
  }
}
