import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class MapTest extends StatefulWidget {
  const MapTest({super.key});

  @override
  State<MapTest> createState() => _MapTestState();
}

class _MapTestState extends State<MapTest> {
  late KakaoMapController mapController;
  String message = "";
  String address2 = "";

  coord2Address(LatLng lng) async {
    final request = Coord2AddressRequest(
      x: lng.longitude,
      y: lng.latitude,
    );
    final response = await mapController.coord2Address(request);
    print("waiting done");
    final coord2address = response.list.first;

    print("response: $response \n coor2address: $coord2address");

    final request2 = Coord2RegionCodeRequest(
      x: lng.longitude,
      y: lng.latitude,
    );
    final response2 = await mapController.coord2RegionCode(request2);
    final coord2RegionCode = response2.list.first;

    setState(() {
      address2 = '';
      if (coord2address.roadAddress != null) {
        address2 += '도로명주소 : ${coord2address.roadAddress?.addressName}\n';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("맛장")),
      body: Stack(children: [
        KakaoMap(
          onMapCreated: ((controller) async {
            mapController = controller;
            var center = await mapController.getCenter();

            coord2Address(center);
          }),
          onMapTap: ((lag) async {
            await mapController.getCenter();
            coord2Address(lag);
            setState(() {});
          }),
          currentLevel: 6,
          zoomControl: true,
          zoomControlPosition: ControlPosition.bottomRight,
        ),
      ]),
    );
  }
}
