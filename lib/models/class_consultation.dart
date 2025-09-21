import 'class_users.dart';

class Consultation {
  final String id;
  final User client;
  final User adviser;
  final String type;
  final DateTime scheduledDate;
  final int duration;
  final String method;
  final String status;
  final String notes;
  final List<String> visaPathways;
  final String clientToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consultation({
    required this.id,
    required this.client,
    required this.adviser,
    required this.type,
    required this.scheduledDate,
    required this.duration,
    required this.method,
    required this.status,
    required this.notes,
    required this.visaPathways,
    required this.clientToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['_id'] ?? '',
      client: User.fromJson(json['clientId'] ?? {}),
      adviser: User.fromJson(json['adviserId'] ?? {}),
      type: json['type'] ?? '',
      scheduledDate: DateTime.tryParse(json['scheduledDate'] ?? '') ?? DateTime(1970),
      duration: json['duration'] ?? 0,
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
      visaPathways: (json['visaPathways'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      clientToken: json['clientToken'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime(1970),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clientId': client.toJson(),
      'adviserId': adviser.toJson(),
      'type': type,
      'scheduledDate': scheduledDate.toIso8601String(),
      'duration': duration,
      'method': method,
      'status': status,
      'notes': notes,
      'visaPathways': visaPathways,
      'clientToken': clientToken,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Consultation.empty() {
    return Consultation(
      id: '',
      client: User.empty(),
      adviser: User.empty(),
      type: '',
      scheduledDate: DateTime.now(),
      duration: 0,
      method: '',
      status: '',
      notes: '',
      visaPathways: [],
      clientToken: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
