class TaskModel {
  String id;
  String title;
  String? description;
  DateTime? startDate;
  DateTime? dueDate;
  String status;
  String priority;
  String? assignedUserId;
  String? assignedUserName;
  String? project;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.dueDate,
    required this.status,
    this.priority = 'medium',
    this.assignedUserId,
    this.assignedUserName,
    this.project,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final assigned = json['assignedUser'];
    String? assignedId;
    String? assignedName;
    if (assigned != null) {
      if (assigned is Map) {
        assignedId = assigned['_id']?.toString();
        assignedName = assigned['name']?.toString();
      } else {
        assignedId = assigned.toString();
      }
    }
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }
    return TaskModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['taskName']?.toString() ?? '',
      description: json['description']?.toString(),
      startDate: parseDate(json['startDate']),
      dueDate: parseDate(json['dueDate']),
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority']?.toString() ?? 'medium',
      assignedUserId: assignedId,
      assignedUserName: assignedName,
      project: json['project']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description ?? '',
      'status': status,
      'priority': priority,
      'project': project ?? '',
    };
    if (startDate != null) map['startDate'] = startDate!.toIso8601String();
    if (dueDate != null) map['dueDate'] = dueDate!.toIso8601String();
    if (assignedUserId != null && assignedUserId!.isNotEmpty) {
      map['assignedUser'] = assignedUserId;
    }
    return map;
  }
}
