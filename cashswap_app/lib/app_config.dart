import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000'; // iOS simulator
  // static const String baseUrl = 'https://api.cashswap.app'; // Production

  static const String wsBaseUrl = 'ws://10.0.2.2:8000';
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const double initialRadiusKm = 2.0;
  static const int requestExpiryMinutes = 30;
}

class SecureStore {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'cashswap_jwt';
  static const _userIdKey = 'cashswap_user_id';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  static Future<String?> getUserId() => _storage.read(key: _userIdKey);

  static Future<void> clear() => _storage.deleteAll();
}
