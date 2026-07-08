import 'package:dio/dio.dart';

class ApiService {

  final Dio dio = Dio();

  final String baseUrl =
      'http://localhost:8000';

Future<dynamic> createRequest({
  required String userId,
  required String requestType,
  required int amount,
  required double latitude,
  required double longitude,
}) async {

    final response = await dio.post(
      '$baseUrl/create-request',
     data: {
  "user_id": userId,
  "request_type": requestType,
  "amount": amount,
  "latitude": latitude,
  "longitude": longitude,
},
    );

    return response.data;
  }
}