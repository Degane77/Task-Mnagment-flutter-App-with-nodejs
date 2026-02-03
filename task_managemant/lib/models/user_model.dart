class UserModel {
  String id;
  String name;
  String email;
  String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get canCreateTask => isAdmin || isManager;
  bool get canDeleteTask => isAdmin || isManager;
  bool get canManageUsers => isAdmin;
}
