import 'package:get_storage/get_storage.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static final _box = GetStorage();

  static void saveToken(String token) {
    _box.write(_tokenKey, token);
  }

  static String? getToken() {
    return _box.read<String>(_tokenKey);
  }

  static void saveUser(Map<String, dynamic> user) {
    _box.write(_userKey, user);
  }

  static Map<String, dynamic>? getUser() {
    return _box.read<Map<String, dynamic>>(_userKey);
  }

  static void clearAuth() {
    _box.remove(_tokenKey);
    _box.remove(_userKey);
  }

  static bool get isLoggedIn => (getToken() ?? '').isNotEmpty;
}
