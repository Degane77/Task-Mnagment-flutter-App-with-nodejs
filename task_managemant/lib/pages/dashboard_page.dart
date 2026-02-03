import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../controllers/user_controller.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

const _bluePrimary = Color(0xFF1976D2);
const _blueLight = Color(0xFF42A5F5);

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
          title: Text("Task Management Dashboard"),
          backgroundColor: _bluePrimary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.task_alt), text: "Tasks"),
              if (authController.canManageUsers) Tab(icon: Icon(Icons.people), text: "Users"),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(child: Text(authController.currentUserRole.toUpperCase(), style: TextStyle(fontSize: 12))),
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => authController.logout(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _TasksTab(controller: taskController, authController: authController, userController: userController),
            if (authController.canManageUsers) _UsersTab(controller: userController),
          ],
        ),
      ),
    );
  }
}

class _TasksTab extends StatefulWidget {
  final TaskController controller;
  final AuthController authController;
  final UserController userController;

  const _TasksTab({required this.controller, required this.authController, required this.userController});

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.authController.canCreateTask)
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Add Task"),
                    style: OutlinedButton.styleFrom(foregroundColor: _bluePrimary),
                    onPressed: () => _showAddTaskDialog(context),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Obx(() {
            if (widget.controller.isLoading.value) {
              return Center(child: CircularProgressIndicator(color: _bluePrimary));
            }
            if (widget.controller.tasks.isEmpty) {
              return Center(child: Text("No tasks yet."));
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.controller.tasks.length,
              itemBuilder: (context, i) {
                final task = widget.controller.tasks[i];
                return _TaskTile(
                  task: task,
                  authController: widget.authController,
                  onCycleStatus: () {
                    final next = task.status == 'pending' ? 'in-progress' : task.status == 'in-progress' ? 'completed' : 'pending';
                    widget.controller.updateTaskStatus(task.id, next);
                  },
                  onEdit: () => _showEditTaskDialog(context, task, widget.controller, widget.userController),
                  onDelete: () => widget.controller.deleteTask(task.id),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final projectController = TextEditingController();
    DateTime? startDate;
    DateTime? dueDate;
    var status = 'pending';
    var priority = 'medium';
    String? assignedUserId;
    final users = widget.userController.users;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Add Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Task Title", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: "Description", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.calendar_today, size: 18),
                        label: Text(startDate == null ? "Start Date" : "${startDate!.day}/${startDate!.month}/${startDate!.year}"),
                        onPressed: () async {
                          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                          if (d != null) setState(() => startDate = d);
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.event, size: 18),
                        label: Text(dueDate == null ? "Due Date" : "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}"),
                        onPressed: () async {
                          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                          if (d != null) setState(() => dueDate = d);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: InputDecoration(labelText: "Status", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                  items: ['pending', 'in-progress', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s == 'in-progress' ? 'In Progress' : s[0].toUpperCase() + s.substring(1)))).toList(),
                  onChanged: (v) => setState(() => status = v ?? 'pending'),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: InputDecoration(labelText: "Priority", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                  items: ['low', 'medium', 'high'].map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
                  onChanged: (v) => setState(() => priority = v ?? 'medium'),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: assignedUserId,
                  decoration: InputDecoration(labelText: "Assigned User", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                  items: [
                    DropdownMenuItem<String?>(value: null, child: Text("— None —")),
                    ...users.map((u) => DropdownMenuItem<String?>(value: u.id, child: Text("${u.name} (${u.email})"))),
                  ],
                  onChanged: (v) => setState(() => assignedUserId = v),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: projectController,
                  decoration: InputDecoration(labelText: "Project", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _bluePrimary),
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  Get.snackbar("Error", "Task title is required");
                  return;
                }
                final task = TaskModel(
                  id: '',
                  title: title,
                  description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  startDate: startDate,
                  dueDate: dueDate,
                  status: status,
                  priority: priority,
                  assignedUserId: assignedUserId,
                  project: projectController.text.trim().isEmpty ? null : projectController.text.trim(),
                );
                widget.controller.addTask(task);
                Get.back();
              },
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, TaskModel task, TaskController controller, UserController userController) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description ?? '');
    final projectController = TextEditingController(text: task.project ?? '');
    var startDate = task.startDate;
    var dueDate = task.dueDate;
    var status = task.status;
    var priority = task.priority;
    var assignedUserId = task.assignedUserId;
    final users = userController.users;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Task Title", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: "Description", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.calendar_today, size: 18),
                        label: Text(startDate == null ? "Start Date" : "${startDate!.day}/${startDate!.month}/${startDate!.year}"),
                        onPressed: () async {
                          final d = await showDatePicker(context: context, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                          if (d != null) setState(() => startDate = d);
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.event, size: 18),
                        label: Text(dueDate == null ? "Due Date" : "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}"),
                        onPressed: () async {
                          final d = await showDatePicker(context: context, initialDate: dueDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                          if (d != null) setState(() => dueDate = d);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: InputDecoration(labelText: "Status", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                  items: ['pending', 'in-progress', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s == 'in-progress' ? 'In Progress' : s[0].toUpperCase() + s.substring(1)))).toList(),
                  onChanged: (v) => setState(() => status = v ?? 'pending'),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: InputDecoration(labelText: "Priority", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                  items: ['low', 'medium', 'high'].map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
                  onChanged: (v) => setState(() => priority = v ?? 'medium'),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: assignedUserId,
                  decoration: InputDecoration(labelText: "Assigned User", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                  items: [
                    DropdownMenuItem<String?>(value: null, child: Text("— None —")),
                    ...users.map((u) => DropdownMenuItem<String?>(value: u.id, child: Text("${u.name} (${u.email})"))),
                  ],
                  onChanged: (v) => setState(() => assignedUserId = v),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: projectController,
                  decoration: InputDecoration(labelText: "Project", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _bluePrimary),
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  Get.snackbar("Error", "Task title is required");
                  return;
                }
                final updated = TaskModel(
                  id: task.id,
                  title: title,
                  description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  startDate: startDate,
                  dueDate: dueDate,
                  status: status,
                  priority: priority,
                  assignedUserId: assignedUserId,
                  assignedUserName: task.assignedUserName,
                  project: projectController.text.trim().isEmpty ? null : projectController.text.trim(),
                );
                controller.updateTaskFull(updated);
                Get.back();
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

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
      case 'pending': return _bluePrimary;
      case 'in-progress': return _blueLight;
      case 'completed': return Colors.green;
      default: return _bluePrimary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.schedule;
      case 'in-progress': return Icons.play_circle_outline;
      case 'completed': return Icons.check_circle;
      default: return Icons.schedule;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _statusColor(task.status).withValues(alpha: 0.5), width: 1),
      ),
      child: ListTile(
        leading: IconButton(
          icon: Icon(_statusIcon(task.status), color: _statusColor(task.status)),
          onPressed: onCycleStatus,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: task.status == 'in-progress' ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(task.description!, style: TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(task.status == 'in-progress' ? 'In Progress' : task.status[0].toUpperCase() + task.status.substring(1), style: TextStyle(fontSize: 10)),
                  backgroundColor: _statusColor(task.status).withValues(alpha: 0.2),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(task.priority[0].toUpperCase() + task.priority.substring(1), style: TextStyle(fontSize: 10)),
                  backgroundColor: _priorityColor(task.priority).withValues(alpha: 0.2),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
                if (task.assignedUserName != null && task.assignedUserName!.isNotEmpty)
                  Chip(
                    avatar: Icon(Icons.person, size: 16, color: _bluePrimary),
                    label: Text(task.assignedUserName!, style: TextStyle(fontSize: 10)),
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                if (task.project != null && task.project!.isNotEmpty)
                  Chip(
                    avatar: Icon(Icons.folder, size: 16, color: _bluePrimary),
                    label: Text(task.project!, style: TextStyle(fontSize: 10)),
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                if (task.startDate != null)
                  Text("Start: ${task.startDate!.day}/${task.startDate!.month}/${task.startDate!.year}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                if (task.dueDate != null)
                  Text("Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit, color: _bluePrimary), onPressed: onEdit),
            if (authController.canDeleteTask)
              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatefulWidget {
  final UserController controller;

  const _UsersTab({required this.controller});

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var selectedRole = 'user';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Name",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary)),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary)),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary)),
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(labelText: "Role", border: OutlineInputBorder()),
                  items: ['admin', 'manager', 'user'].map((r) => DropdownMenuItem(value: r, child: Text(r[0].toUpperCase() + r.substring(1)))).toList(),
                  onChanged: (v) => setState(() => selectedRole = v ?? 'user'),
                ),
              ),
              SizedBox(width: 8),
              IconButton.filled(
                icon: Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: _bluePrimary),
                onPressed: () {
                  widget.controller.addUser(nameController.text, emailController.text, passwordController.text, role: selectedRole);
                  nameController.clear();
                  emailController.clear();
                  passwordController.clear();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (widget.controller.isLoading.value) {
              return Center(child: CircularProgressIndicator(color: _bluePrimary));
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.controller.users.length,
              itemBuilder: (c, i) {
                final user = widget.controller.users[i];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(user.name),
                    subtitle: Row(
                      children: [
                        Text(user.email),
                        SizedBox(width: 8),
                        Chip(label: Text(user.role.toUpperCase(), style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit, color: _bluePrimary), onPressed: () => _showEditUserDialog(user)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => widget.controller.deleteUser(user.id)),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showEditUserDialog(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    var role = user.role;
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary)))),
              SizedBox(height: 12),
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary)))),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: InputDecoration(labelText: "Role", focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bluePrimary))),
                items: ['admin', 'manager', 'user'].map((r) => DropdownMenuItem(value: r, child: Text(r[0].toUpperCase() + r.substring(1)))).toList(),
                onChanged: (v) => setState(() => role = v ?? 'user'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _bluePrimary),
              onPressed: () {
                widget.controller.updateUser(user.id, nameController.text, emailController.text, role: role);
                Get.back();
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
