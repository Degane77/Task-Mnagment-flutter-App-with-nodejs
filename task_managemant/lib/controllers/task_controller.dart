import 'dart:convert';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskController extends GetxController {
  /// Observable list of tasks (auto updates UI when changed)
  final tasks = <TaskModel>[].obs;

  /// Observable loading state (used to show loader/spinner in UI)
  final isLoading = false.obs;

  /// ------------------------------------------------------------
  /// Helper: Show snackbar messages in a consistent way
  /// ------------------------------------------------------------
  void _showError(String message) {
    Get.snackbar("Error", message);
  }

  void _showSuccess(String message) {
    Get.snackbar("Success", message);
  }

  /// ------------------------------------------------------------
  /// Helper: Extract backend error message from response body
  /// Expected response format: { "message": "Something went wrong" }
  /// ------------------------------------------------------------
  String _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body);

      // Ensure it is a JSON object
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? 'Request failed';
      }

      return "Request failed";
    } catch (_) {
      // If backend response is not JSON
      return 'Request failed';
    }
  }

  /// ------------------------------------------------------------
  /// Called automatically when controller is created
  /// ------------------------------------------------------------
  @override
  void onInit() {
    fetchTasks(); // Load tasks immediately when app opens
    super.onInit();
  }

  /// ------------------------------------------------------------
  /// Fetch all tasks from backend API
  /// ------------------------------------------------------------
  Future<void> fetchTasks() async {
    isLoading(true);

    try {
      // Call API service
      final result = await ApiService.getTasks();

      // Update observable list (UI refreshes automatically)
      tasks.value = result;
    } catch (e) {
      // If error happens, show message
      _showError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  /// ------------------------------------------------------------
  /// Create a new task in backend
  /// ------------------------------------------------------------
  Future<void> addTask(TaskModel task) async {
    try {
      final res = await ApiService.createTask(task);

      if (res.statusCode == 201) {
        _showSuccess("Task created successfully");
        fetchTasks();
      } else {
        _showError(_parseErrorMessage(res.body));
      }
    } catch (e) {
      _showError("Connection failed. Check if backend is running.");
    }
  }

  /// ------------------------------------------------------------
  /// Update full task information (title, dates, description, etc.)
  /// ------------------------------------------------------------
  Future<void> updateTaskFull(TaskModel task) async {
    try {
      final res = await ApiService.updateTask(task.id, task);

      if (res.statusCode == 200) {
        _showSuccess("Task updated successfully");
        fetchTasks();
      } else {
        _showError(_parseErrorMessage(res.body));
      }
    } catch (e) {
      _showError("Connection failed. Check if backend is running.");
    }
  }

  /// ------------------------------------------------------------
  /// Update only the task status (example: Pending -> Completed)
  ///
  /// Enhancement:
  /// - Optimistic UI update: UI changes immediately before API response
  /// - If API fails, it restores old value
  /// ------------------------------------------------------------
  Future<void> updateTaskStatus(String id, String status) async {
    try {
      // Find task index inside list
      final idx = tasks.indexWhere((t) => t.id == id);
      if (idx < 0) return;

      final oldTask = tasks[idx];

      // Create updated task object (same task but new status)
      final updatedTask = TaskModel(
        id: oldTask.id,
        title: oldTask.title,
        description: oldTask.description,
        startDate: oldTask.startDate,
        dueDate: oldTask.dueDate,
        status: status,
        priority: oldTask.priority,
        assignedUserId: oldTask.assignedUserId,
        assignedUserName: oldTask.assignedUserName,
        project: oldTask.project,
      );

      //  Optimistic update (fast UI)
      tasks[idx] = updatedTask;

      // Send request to backend
      final res = await ApiService.updateTask(id, updatedTask);

      if (res.statusCode == 200) {
        _showSuccess("Status updated");
      } else {
        //  Restore old task if backend rejects
        tasks[idx] = oldTask;
        _showError(_parseErrorMessage(res.body));
      }
    } catch (e) {
      _showError("Connection failed. Check if backend is running.");
    }
  }

  /// ------------------------------------------------------------
  /// Delete task by ID
  ///
  /// Enhancement:
  /// - Optimistic delete: removes immediately
  /// - If API fails, it restores task
  /// ------------------------------------------------------------
  Future<void> deleteTask(String id) async {
    try {
      // Find task index
      final idx = tasks.indexWhere((t) => t.id == id);
      if (idx < 0) return;

      final removedTask = tasks[idx];

      //  Optimistic remove
      tasks.removeAt(idx);

      final res = await ApiService.deleteTask(id);

      if (res.statusCode == 200) {
        _showSuccess("Task deleted");
      } else {
        //  Restore task if delete failed
        tasks.insert(idx, removedTask);
        _showError(_parseErrorMessage(res.body));
      }
    } catch (e) {
      _showError("Connection failed. Check if backend is running.");
    }
  }
}
