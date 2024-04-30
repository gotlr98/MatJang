import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MapTest.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(
        () => setState(() => selectedIndex = _tabController.index));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var curUser = FirebaseAuth.instance.currentUser;
    // var email = curUser?.email;
    // var userEmail =
    //     email == null ? "guest" : email.substring(0, email.indexOf("@"));
    return Scaffold(
      appBar: selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.amber.shade50,
              title: const Text(
                "Hi",
              ),
              actions: const [
                // ButtonTheme(
                //   alignedDropdown: true,
                //   child: DropdownButton(
                //     underline: const SizedBox.shrink(),
                //     icon: const Icon(Icons.more_vert),
                //     items: const [
                //       DropdownMenuItem(value: "1", child: Text("register"))
                //     ],
                //     onChanged: (String? newValue) {
                //       Get.bottomSheet(SingleChildScrollView(
                //         child: SizedBox(
                //             height: MediaQuery.of(context).size.height * 0.8,
                //             child: const RegisterDrink()),
                //       ));
                //     },
                //   ),
                // ),
              ],
            )
          : AppBar(),
      bottomNavigationBar: SizedBox(
          height: 80,
          child: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                icon:
                    Icon(selectedIndex == 0 ? Icons.home : Icons.home_outlined),
                text: "home",
              ),
              Tab(
                icon: Icon(
                    selectedIndex == 1 ? Icons.person : Icons.person_outlined),
                text: "profile",
              )
            ],
            indicatorColor: Colors.amber.shade500,
          )),
      body: selectedIndex == 0 ? const MapTest() : const MapTest(),
    );
  }
}
