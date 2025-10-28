import 'package:Migrantifly/models/class_users.dart';
import 'class_applications.dart';

class Document {
  final String id;
  final Application? applicationId;
  final User? clientId;
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
  final DateTime? expiryDate;
  final bool isRequired;
  final int v;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    this.applicationId,
    this.clientId,
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
    this.expiryDate,
    required this.isRequired,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['_id']?.toString() ?? '',
      applicationId: (json['applicationId'] is Map<String, dynamic>)
          ? Application.fromJson(json['applicationId'])
          : null,
      clientId: (json['clientId'] is Map<String, dynamic>)
          ? User.fromJson(json['clientId'])
          : null,
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      originalName: json['originalName']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      mimeType: json['mimeType']?.toString() ?? 'application/octet-stream',
      status: json['status']?.toString() ?? '',
      reviewNotes: json['reviewNotes']?.toString() ?? '',
      reviewedBy: (json['reviewedBy'] != null &&
          json['reviewedBy'] is Map<String, dynamic>)
          ? User.fromJson(json['reviewedBy'])
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'].toString())
          : null,
      isRequired: (json['isRequired'] as bool?) ?? false,
      v: (json['__v'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "applicationId": applicationId?.toJson(),
      "clientId": clientId?.toJson(),
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
      "expiryDate": expiryDate?.toIso8601String(),
      "isRequired": isRequired,
      "__v": v,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  static List<Document> listFromJson(List<dynamic> data) {
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => Document.fromJson(e))
        .toList();
  }
}