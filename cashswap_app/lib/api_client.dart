import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: '${AppConfig.baseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStore.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired – navigate to login
          // This is handled by GoRouter redirect
        }
        return handler.next(error);
      },
    ));
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> loginWithFirebase(String firebaseToken) async {
    final res = await _dio.post('/auth/login', data: {
      'firebase_id_token': firebaseToken,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<void> updateLocation(double lat, double lng) async {
    await _dio.post('/auth/location', data: {
      'latitude': lat,
      'longitude': lng,
    });
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  // ── Requests ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createRequest({
    required String requestType,
    required double amount,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    final res = await _dio.post('/requests/', data: {
      'request_type': requestType,
      'amount': amount,
      'latitude': latitude,
      'longitude': longitude,
      if (description != null) 'description': description,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getNearbyRequests({
    required double lat,
    required double lng,
    String? requestType,
    double radiusKm = 10.0,
  }) async {
    final res = await _dio.get('/requests/nearby', queryParameters: {
      'latitude': lat,
      'longitude': lng,
      if (requestType != null) 'request_type': requestType,
      'radius_km': radiusKm,
    });
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getMyRequests() async {
    final res = await _dio.get('/requests/my');
    return res.data as List<dynamic>;
  }

  Future<void> cancelRequest(String requestId) async {
    await _dio.delete('/requests/$requestId');
  }

  // ── Matches ───────────────────────────────────────────────────────────────

  Future<List<dynamic>> getMyMatches() async {
    final res = await _dio.get('/matches/');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> matchAction(
      String matchId, String action) async {
    final res = await _dio.post('/matches/$matchId/action', data: {
      'action': action,
    });
    return res.data as Map<String, dynamic>;
  }

  // ── Ratings ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitRating({
    required String matchId,
    required String rateeId,
    required int score,
    String? comment,
  }) async {
    final res = await _dio.post('/ratings/', data: {
      'match_id': matchId,
      'ratee_id': rateeId,
      'score': score,
      if (comment != null) 'comment': comment,
    });
    return res.data as Map<String, dynamic>;
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final res = await _dio.get('/users/$userId');
    return res.data as Map<String, dynamic>;
  }
}
