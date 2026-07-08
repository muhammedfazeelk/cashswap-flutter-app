import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';


import 'chat_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Dio dio = Dio();

  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : 'http://192.168.1.5:8000';

  List<dynamic> requests = [];

  bool isLoading = true;

  String currentRequestType =
      "Need Physical Cash";

  LatLng currentLocation =
      const LatLng(10.7415, 76.0405);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await getCurrentLocation();
    await fetchRequests();
  }

  Future<void> getCurrentLocation() async {
    try {

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
            await Geolocator.requestPermission();
      }

      Position position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );

      setState(() {
        currentLocation = LatLng(
          position.latitude,
          position.longitude,
        );
      });

      print(
          "CURRENT LOCATION:");
      print(position.latitude);
      print(position.longitude);

    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchRequests() async {
    setState(() {
      isLoading = true;
    });

    try {

      final userId =
          FirebaseAuth.instance
              .currentUser!
              .uid;

      final response = await dio.get(
        '$baseUrl/map-requests/$currentRequestType/$userId',
      );

      print(
          "REQUEST COUNT: ${response.data.length}");
      print(response.data);

      setState(() {
        requests = response.data;
      });

    } catch (e) {

      print("MAP ERROR:");
      print(e);

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(e.toString()),
          ),
        );
      }

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

 void openChat(dynamic request) {

  final myUid =
      FirebaseAuth.instance.currentUser!.uid;

  final otherUid =
      request["user_id"];

  List<String> users = [
    myUid,
    otherUid,
  ];

  users.sort();

  final roomId =
      users.join("_");

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        roomId: roomId,
      ),
    ),
  );
}

  List<Marker> buildMarkers() {

    List<Marker> markers = [];

    markers.add(
      Marker(
        point: currentLocation,
        width: 80,
        height: 80,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );

    for (var request in requests) {

      try {

        final double? lat =
            double.tryParse(
          request["latitude"]
              .toString(),
        );

        final double? lng =
            double.tryParse(
          request["longitude"]
              .toString(),
        );

        if (lat == null ||
            lng == null) {
          continue;
        }

        markers.add(
          Marker(
            point:
                LatLng(lat, lng),
            width: 90,
            height: 90,
            child:
                GestureDetector(
              onTap: () {

                showModalBottomSheet(
                  context: context,
                  builder: (_) {

                    return Padding(
                      padding:
                          const EdgeInsets
                              .all(24),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Text(
                            request[
                                "request_type"],
                            style:
                                const TextStyle(
                              fontSize:
                                  22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              height:
                                  15),

                          Text(
                            "Amount: ₹${request["amount"]}",
                          ),

                          const SizedBox(
                              height:
                                  10),

                          Text(
                            "Rating: ${request["rating"]}",
                          ),

                          const SizedBox(
                              height:
                                  10),

                          Text(
                            "Completed Exchanges: ${request["completed_exchanges"]}",
                          ),

                          const SizedBox(
                              height:
                                  25),

                          SizedBox(
                            width:
                                double
                                    .infinity,
                            height: 55,
                            child:
                                ElevatedButton(
                             onPressed: () async {

  try {

    final userId =
        FirebaseAuth.instance.currentUser!.uid;

    await dio.put(
      '$baseUrl/accept-request/${request["id"]}/$userId',
    );

    Navigator.pop(context);

    openChat(request);

  } catch (e) {

    print(e);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Unable to accept request",
        ),
      ),
    );
  }
},
                              child:
                               const Text(
  "Accept Request",
), 
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 45,
              ),
            ),
          ),
        );

      } catch (e) {

        print(
            "MARKER ERROR:");
        print(e);
      }
    }

    return markers;
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(
              0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        elevation: 0,

        title: const Text(
          "Nearby Matches",
          style: TextStyle(
            color:
                Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(
            onPressed:
                loadData,
            icon: const Icon(
              Icons.refresh,
              color:
                  Colors.blue,
            ),
          ),
        ],
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : FlutterMap(
              options:
                  MapOptions(
                initialCenter:
                    currentLocation,
                initialZoom:
                    13,
              ),

              children: [

                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.cashswap.app',
                ),

                MarkerLayer(
                  markers:
                      buildMarkers(),
                ),
              ],
            ),
    );
  }
}
