import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../controllers/user_controller.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

// 🔴 RED THEME COLORS
const _redPrimary = Color(0xFFD32F2F);
const _redLight = Color(0xFFEF5350);

class DashboardPage extends StatelessWidget {
  final taskController = Get.put(TaskController());
  final userController = Get.put(UserController());
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: authController.canManageUsers ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Task Management Dashboard"),
          backgroundColor: _redPrimary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.task_alt), text: "Tasks"),
              Tab(icon: Icon(Icons.people), text: "Users"),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  authController.currentUserRole.toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authController.logout(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _TasksTab(
              controller: taskController,
              authController: authController,
              userController: userController,
            ),
            if (authController.canManageUsers)
              _UsersTab(controller: userController),
          ],
        ),
      ),
    );
  }
}

/* ===================== TASKS TAB ===================== */

class _TasksTab extends StatelessWidget {
  final TaskController controller;
  final AuthController authController;
  final UserController userController;

  const _TasksTab({
    required this.controller,
    required this.authController,
    required this.userController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (authController.canCreateTask)
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
              style: OutlinedButton.styleFrom(foregroundColor: _redPrimary),
              onPressed: () {},
            ),
          ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: _redPrimary),
              );
            }
            if (controller.tasks.isEmpty) {
              return const Center(child: Text("No tasks yet"));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.tasks.length,
              itemBuilder: (_, i) {
                return _TaskTile(
                  task: controller.tasks[i],
                  authController: authController,
                  onCycleStatus: () {},
                  onEdit: () {},
                  onDelete: () {},
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

/* ===================== TASK TILE ===================== */

class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final AuthController authController;
  final VoidCallback onCycleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.authController,
    required this.onCycleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return _redPrimary;
      case 'in-progress':
        return _redLight;
      case 'completed':
        return Colors.green;
      default:
        return _redPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _statusColor(task.status), width: 1),
      ),
      child: ListTile(
        leading: IconButton(
          icon: Icon(Icons.task, color: _statusColor(task.status)),
          onPressed: onCycleStatus,
        ),
        title: Text(task.title),
        subtitle: Wrap(
          spacing: 6,
          children: [
            Chip(
              label: Text(task.status),
              backgroundColor: _statusColor(task.status).withOpacity(0.2),
            ),
            Chip(
              label: Text(task.priority),
              backgroundColor: Colors.grey.withOpacity(0.2),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: _redPrimary),
              onPressed: onEdit,
            ),
            if (authController.canDeleteTask)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

/* ===================== USERS TAB ===================== */

class _UsersTab extends StatelessWidget {
  final UserController controller;

  const _UsersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: _redPrimary),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.users.length,
        itemBuilder: (_, i) {
          final user = controller.users[i];
          return Card(
            child: ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Chip(
                label: Text(user.role.toUpperCase()),
                backgroundColor: _redPrimary.withOpacity(0.2),
              ),
            ),
          );
        },
      );
    });
  }
}
