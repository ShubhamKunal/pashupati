import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _tokenKey = 'pashupati_auth_token';
  static const _userIdKey = 'pashupati_user_id';
  static const _phoneKey = 'pashupati_user_phone';
  static const _userNameKey = 'pashupati_user_name';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveAuthSession({
    required String token,
    required String userId,
    required String phone,
    required String name,
  }) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userIdKey, value: userId);
    await _secureStorage.write(key: _phoneKey, value: phone);
    await _secureStorage.write(key: _userNameKey, value: name);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  Future<String?> getUserPhone() async {
    return await _secureStorage.read(key: _phoneKey);
  }

  Future<String?> getUserName() async {
    return await _secureStorage.read(key: _userNameKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
  }
}

