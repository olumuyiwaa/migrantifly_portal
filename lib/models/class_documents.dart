import 'package:Migrantifly/models/class_users.dart';

import 'class_applications.dart';

class Document {
  final String id;
  final Application applicationId;
  final User clientId;
  final String type;
  final String name;
  final String originalName;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final String status;
  final String reviewNotes;
  final User? reviewedBy;
  final DateTime? reviewedAt;
  final bool isRequired;
  final int v;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.applicationId,
    required this.clientId,
    required this.type,
    required this.name,
    required this.originalName,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    required this.status,
    required this.reviewNotes,
    this.reviewedBy,
    this.reviewedAt,
    required this.isRequired,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['_id'],
      applicationId: Application.fromJson(json['applicationId']),
      clientId: User.fromJson(json['clientId']),
      type: json['type'],
      name: json['name'],
      originalName: json['originalName'],
      fileUrl: json['fileUrl'],
      fileSize: json['fileSize'],
      mimeType: json['mimeType'],
      status: json['status'],
      reviewNotes: json['reviewNotes'],
      reviewedBy:
          json['reviewedBy'] != null ? User.fromJson(json['reviewedBy']) : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      isRequired: json['isRequired'] ?? false,
      v: json['__v'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "applicationId": applicationId.toJson(),
      "clientId": clientId.toJson(),
      "type": type,
      "name": name,
      "originalName": originalName,
      "fileUrl": fileUrl,
      "fileSize": fileSize,
      "mimeType": mimeType,
      "status": status,
      "reviewNotes": reviewNotes,
      "reviewedBy": reviewedBy?.toJson(),
      "reviewedAt": reviewedAt?.toIso8601String(),
      "isRequired": isRequired,
      "__v": v,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}