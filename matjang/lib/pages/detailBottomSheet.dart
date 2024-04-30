import 'package:flutter/material.dart';

class DetailBottomSheet extends StatelessWidget {
  DetailBottomSheet({super.key, this.place_name, this.address});
  String? place_name;
  String? address;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [Text(place_name!), Text(address!)],
      ),
    );
  }
}
