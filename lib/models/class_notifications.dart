class NotificationModel {
  final String id;
  final String userId;
  final String applicationId;
  final String type;
  final String title;
  final String message;
  final String priority;
  final bool actionRequired;
  final String? actionUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.applicationId,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    required this.actionRequired,
    this.actionUrl,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      applicationId: json['applicationId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? '',
      actionRequired: json['actionRequired'] ?? false,
      actionUrl: json['actionUrl'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'applicationId': applicationId,
      'type': type,
      'title': title,
      'message': message,
      'priority': priority,
      'actionRequired': actionRequired,
      'actionUrl': actionUrl,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
