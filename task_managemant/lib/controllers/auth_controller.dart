import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../pages/dashboard_page.dart';
import '../pages/login_page.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  void login(String email, String password) async {
    isLoading(true);
    try {
      final res = await ApiService.login(email, password);
      isLoading(false);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        final user = data['user'] as Map<String, dynamic>?;
        if (token != null && token.isNotEmpty) {
          StorageService.saveToken(token);
          if (user != null) {
            StorageService.saveUser(user);
          }
        }
        Get.offAll(DashboardPage());
      } else {
        final message = _parseErrorMessage(res.body);
        Get.snackbar("Error", message);
      }
    } catch (e) {
      isLoading(false);
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }

  void signup(String name, String email, String password) async {
    try {
      final res = await ApiService.signup(name, email, password);
      if (res.statusCode == 201) {
        Get.back();
      } else {
        final message = _parseErrorMessage(res.body);
        Get.snackbar("Error", message);
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }

  void logout() {
    StorageService.clearAuth();
    Get.offAll(LoginPage());
  }

  String get currentUserRole => StorageService.getUser()?['role']?.toString() ?? 'user';
  String? get currentUserId => StorageService.getUser()?['id']?.toString();
  bool get isAdmin => currentUserRole == 'admin';
  bool get isManager => currentUserRole == 'manager';
  bool get canCreateTask => isAdmin || isManager;
  bool get canDeleteTask => isAdmin || isManager;
  bool get canManageUsers => isAdmin;

  String _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['message']?.toString() ?? 'Unknown error';
    } catch (_) {
      return 'Unknown error';
    }
  }
}
