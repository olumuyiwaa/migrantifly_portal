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

  Document copyWith({
    String? id,
    Application? applicationId,
    User? clientId,
    String? type,
    String? name,
    String? originalName,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    String? status,
    String? reviewNotes,
    User? reviewedBy,
    DateTime? reviewedAt,
    DateTime? expiryDate,
    bool? isRequired,
    int? v,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      name: name ?? this.name,
      originalName: originalName ?? this.originalName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isRequired: isRequired ?? this.isRequired,
      v: v ?? this.v,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );}

  static List<Document> listFromJson(List<dynamic> data) {
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => Document.fromJson(e))
        .toList();
  }
}