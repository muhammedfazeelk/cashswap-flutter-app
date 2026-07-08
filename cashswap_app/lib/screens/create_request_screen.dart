import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState
    extends State<CreateRequestScreen> {

  final Dio dio = Dio();

  final TextEditingController amountController =
      TextEditingController();

  String requestType =
      "Need Physical Cash";

  bool isLoading = false;

final String baseUrl = kIsWeb
    ? 'http://127.0.0.1:8000'
    : 'http://192.168.1.5:8000';

  Future<void> createRequest() async {

    setState(() {
      isLoading = true;
    });

    try {

      bool serviceEnabled =
      await Geolocator
          .isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          "Location disabled",
        );
      }

      LocationPermission permission =
      await Geolocator
          .checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
        await Geolocator
            .requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {

        throw Exception(
          "Location permission denied",
        );
      }

      print("GETTING LOCATION...");

      Position position =
      await Geolocator.getCurrentPosition(

        desiredAccuracy:
        LocationAccuracy.high,

        timeLimit:
        const Duration(seconds: 10),
      );

      print(position.latitude);
      print(position.longitude);

      print("SENDING REQUEST...");

      final response = await dio.post(

        '$baseUrl/create-request',

        data: {

          "user_id":
          FirebaseAuth
              .instance
              .currentUser!
              .uid,

          "request_type":
          requestType,

          "amount":
          int.tryParse(
            amountController.text,
          ) ?? 0,

          "latitude":
          position.latitude,

          "longitude":
          position.longitude,
        },
      );

      print(response.data);

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            backgroundColor:
            Color(0xFF2563EB),

            content: Text(
              "Request Created Successfully",
            ),
          ),
        );
      }

      amountController.clear();

    } catch (e) {

  print("ERROR:");
  print(e);

  if (e is DioException) {
    print("STATUS:");
    print(e.response?.statusCode);

    print("BODY:");
    print(e.response?.data);
  }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF8FAFC),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
          const EdgeInsets.all(24),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              const Text(

                "CashSwap",

                style: TextStyle(

                  fontSize: 34,

                  fontWeight:
                  FontWeight.bold,

                  color:
                  Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 8),

              const Text(

                "Instant nearby cash exchange",

                style: TextStyle(

                  fontSize: 16,

                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              Container(

                padding:
                const EdgeInsets.all(24),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(28),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black
                          .withOpacity(0.05),

                      blurRadius: 20,
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(

                      "Exchange Type",

                      style: TextStyle(

                        fontWeight:
                        FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(

                      value:
                      requestType,

                      decoration:
                      InputDecoration(

                        filled: true,

                        fillColor:
                        const Color(0xFFF1F5F9),

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(18),

                          borderSide:
                          BorderSide.none,
                        ),
                      ),

                      items: const [

                        DropdownMenuItem(

                          value:
                          "Need Physical Cash",

                          child: Text(
                            "Need Physical Cash",
                          ),
                        ),

                        DropdownMenuItem(

                          value:
                          "Need Digital Cash",

                          child: Text(
                            "Need Digital Cash",
                          ),
                        ),
                      ],

                      onChanged: (value) {

                        setState(() {

                          requestType =
                          value!;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    const Text(

                      "Amount",

                      style: TextStyle(

                        fontWeight:
                        FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(

                      controller:
                      amountController,

                      keyboardType:
                      TextInputType.number,

                      decoration:
                      InputDecoration(

                        hintText:
                        "Enter amount",

                        filled: true,

                        fillColor:
                        const Color(0xFFF1F5F9),

                        prefixIcon:
                        const Icon(
                          Icons.currency_rupee,
                        ),

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(18),

                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    SizedBox(

                      width:
                      double.infinity,

                      height: 58,

                      child: ElevatedButton(

                        onPressed:
                        isLoading
                            ? null
                            : createRequest,

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          const Color(0xFF2563EB),

                          foregroundColor:
                          Colors.white,

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                        ),

                        child:
                        isLoading

                            ? const CircularProgressIndicator(
                          color:
                          Colors.white,
                        )

                            : const Text(

                          "Create Request",

                          style: TextStyle(

                            fontSize: 18,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}