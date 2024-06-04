import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/matjip.dart';
import '../model/usermodel.dart';

class FindFollowersPage extends StatefulWidget {
  FindFollowersPage({super.key, this.allUserMatjipList});

  Map<String, List<MatJip>>? allUserMatjipList = {};
  @override
  State<FindFollowersPage> createState() => _FindFollowersPageState();
}

class _FindFollowersPageState extends State<FindFollowersPage> {
  late List<bool> isEnabled =
      List.filled(widget.allUserMatjipList!.keys.length, true);

  onPressedFunc(int index) {
    if (isEnabled[index]) {
      isEnabled[index] = false;
    } else {
      isEnabled[index] = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Follower 찾기")),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allUserMatjipList!.keys.length,
          itemBuilder: (context, index) {
            var keys = widget.allUserMatjipList!.keys.toList();
            return ListTile(
                leading: const Icon(Icons.people),
                title: Text(keys[index].split("@")[0]),
                subtitle: Text(
                    "${widget.allUserMatjipList![keys[index]]!.length} 개 후기"),
                trailing: Wrap(
                  children: [
                    ElevatedButton(
                      onPressed:
                          isEnabled[index] ? () => onPressedFunc(index) : null,
                      style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all<Color>(Colors.black12)),
                      child: const Text("Follow"),
                    ),
                    IconButton(
                        onPressed: () {
                          widget.allUserMatjipList!.remove(keys[index]);
                          setState(() {});
                        },
                        icon: const Icon(Icons.cancel))
                  ],
                ));
          },
        ),
      ),
    );
  }
}
