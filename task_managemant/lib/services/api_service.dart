import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Map<String, String> get _headers {
    final headers = {"Content-Type": "application/json"};
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  // AUTH
  static Future<http.Response> login(String email, String password) async {
    return await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
  }

  static Future<http.Response> signup(String name, String email, String password) async {
    return await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
  }

  // USERS CRUD
  static Future<List<UserModel>> getUsers() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/users"), headers: _headers);
      if (res.statusCode != 200) {
        throw Exception(_parseErrorMessage(res.body));
      }
      final data = jsonDecode(res.body) as List;
      return List<UserModel>.from(data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      rethrow;
    }
  }

  static String _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['message']?.toString() ?? 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }

  static Future<http.Response> createUser(String name, String email, String password, {String role = 'user'}) async {
    return await http.post(
      Uri.parse("$baseUrl/users"),
      headers: _headers,
      body: jsonEncode({"name": name, "email": email, "password": password, "role": role}),
    );
  }

  static Future<http.Response> updateUser(String id, String name, String email, {String? role}) async {
    final body = <String, dynamic>{"name": name, "email": email};
    if (role != null) body['role'] = role;
    return await http.put(
      Uri.parse("$baseUrl/users/$id"),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deleteUser(String id) async {
    return await http.delete(Uri.parse("$baseUrl/users/$id"), headers: _headers);
  }

  // TASKS CRUD (requires auth token)
  static Future<List<TaskModel>> getTasks() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/tasks"), headers: _headers);
      if (res.statusCode != 200) {
        throw Exception(_parseErrorMessage(res.body));
      }
      final data = jsonDecode(res.body) as List;
      return List<TaskModel>.from(data.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      rethrow;
    }
  }

  static Future<TaskModel?> getTaskById(String id) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/tasks/$id"), headers: _headers);
      if (res.statusCode != 200) return null;
      return TaskModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<http.Response> createTask(TaskModel task) async {
    return await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
  }

  static Future<http.Response> updateTask(String id, TaskModel task) async {
    return await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
  }

  static Future<http.Response> deleteTask(String id) async {
    return await http.delete(Uri.parse("$baseUrl/tasks/$id"), headers: _headers);
  }
}
