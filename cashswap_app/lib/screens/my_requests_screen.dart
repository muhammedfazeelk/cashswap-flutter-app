import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() =>
      _MyRequestsScreenState();
}

class _MyRequestsScreenState
    extends State<MyRequestsScreen> {

  final Dio dio = Dio();

  List requests = [];

  bool isLoading = true;

  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : 'http://192.168.1.5:8000';

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {

    try {

     final userId =
    FirebaseAuth.instance.currentUser!.uid;

final response = await dio.get(
  '$baseUrl/my-requests/$userId',
);

      setState(() {

        requests = response.data;

        isLoading = false;
      });

      print("REQUESTS LOADED:");
      print(requests);

    } catch (e) {

      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Requests"),
      ),

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : requests.isEmpty

          ? const Center(
        child: Text(
          "No Requests Found",
        ),
      )

          : ListView.builder(

        padding: const EdgeInsets.all(12),

        itemCount: requests.length,

        itemBuilder: (context, index) {

          final request =
          requests[index];

          return Card(

            margin:
            const EdgeInsets.only(
              bottom: 12,
            ),

            child: ListTile(

              leading: const Icon(
                Icons.currency_rupee,
                color: Colors.green,
              ),

              title: Text(
                "₹${request['amount']}",
              ),

              subtitle: Text(
                request['request_type'],
              ),

             trailing: IconButton(
  icon: const Icon(
    Icons.delete,
    color: Colors.red,
  ),
  onPressed: () async {

    try {

      await dio.put(
        '$baseUrl/cancel-request/${request['id']}',
      );

      await loadRequests();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Request Cancelled",
            ),
          ),
        );
      }

    } catch (e) {

      print(e);
    }
  },
),
            ),
          );
        },
      ),
    );
  }
}