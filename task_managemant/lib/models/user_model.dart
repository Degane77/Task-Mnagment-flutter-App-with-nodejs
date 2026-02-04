/// User model representing an authenticated system user
class UserModel {
  /// Unique user ID (usually from backend like MongoDB)
  final String id;

  /// Full name of the user
  final String name;

  /// Email address of the user
  final String email;

  /// Role of the user (admin, manager, user)
  final String role;

  /// Constructor with required fields
  /// Default role is set to 'user'
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
  });

  /// Factory constructor to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
    );
  }

  /// Checks if user is an admin
  bool get isAdmin => role == 'admin';

  /// Checks if user is a manager
  bool get isManager => role == 'manager';

  /// Permission: can create tasks
  bool get canCreateTask => isAdmin || isManager;

  /// Permission: can delete tasks
  bool get canDeleteTask => isAdmin || isManager;

  /// Permission: can manage users
  bool get canManageUsers => isAdmin;
}
