import 'dart:convert';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskController extends GetxController {
  var tasks = <TaskModel>[].obs;
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
    fetchTasks();
    super.onInit();
  }

  void fetchTasks() async {
    isLoading(true);
    try {
      tasks.value = await ApiService.getTasks();
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  void addTask(TaskModel task) async {
    try {
      final res = await ApiService.createTask(task);
      if (res.statusCode == 201) {
        fetchTasks();
      } else {
        Get.snackbar("Error", _parseErrorMessage(res.body));
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }

  void updateTaskFull(TaskModel task) async {
    try {
      final res = await ApiService.updateTask(task.id, task);
      if (res.statusCode == 200) {
        fetchTasks();
      } else {
        Get.snackbar("Error", _parseErrorMessage(res.body));
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }

  void updateTaskStatus(String id, String status) async {
    try {
      final idx = tasks.indexWhere((t) => t.id == id);
      if (idx < 0) return;
      final task = tasks[idx];
      final updated = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        startDate: task.startDate,
        dueDate: task.dueDate,
        status: status,
        priority: task.priority,
        assignedUserId: task.assignedUserId,
        assignedUserName: task.assignedUserName,
        project: task.project,
      );
      final res = await ApiService.updateTask(id, updated);
      if (res.statusCode == 200) {
        fetchTasks();
      } else {
        Get.snackbar("Error", _parseErrorMessage(res.body));
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }

  void deleteTask(String id) async {
    try {
      final res = await ApiService.deleteTask(id);
      if (res.statusCode == 200) {
        fetchTasks();
      } else {
        Get.snackbar("Error", _parseErrorMessage(res.body));
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed. Check if backend is running.");
    }
  }
}
