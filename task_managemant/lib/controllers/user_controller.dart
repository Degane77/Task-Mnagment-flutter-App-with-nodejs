import 'dart:convert';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserController extends GetxController {
  var users = <UserModel>[].obs;
  var isLoading = false.obs;

  String _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['message']?.toString() ?? 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  void fetchUsers() async {
    isLoading(true);
    try {
      users.value = await ApiService.getUsers();
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  void addUser(String name, String email, String password, {String role = 'user'}) async {
    try {
      final res = await ApiService.createUser(name, email, password, role: role);
      if (res.statusCode == 201) {
        fetchUsers();
      } else {
        Get.snackbar("Error", _parseErrorMessage(res.body));
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }

  void updateUser(String id, String name, String email, {String? role}) async {
    try {
      final res = await ApiService.updateUser(id, name, email, role: role);
      if (res.statusCode == 200) {
        fetchUsers();
      } else {
        Get.snackbar("Error", _parseErrorMessage(res.body));
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }

  void deleteUser(String id) async {
    try {
      final res = await ApiService.deleteUser(id);
      if (res.statusCode == 200) {
        fetchUsers();
      } else {
        Get.snackbar("Error", _parseErrorMessage(res.body));
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }
}
