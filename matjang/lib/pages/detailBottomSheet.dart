import 'package:flutter/material.dart';

class DetailBottomSheet extends StatelessWidget {
  DetailBottomSheet({super.key, this.place_name, this.address});
  String? place_name;
  String? address;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place_name!,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              address!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w100),
            )
          ],
        ),
      ),
    );
  }
}
