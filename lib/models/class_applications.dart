// dart
import 'dart:convert';
import 'class_users.dart';

class Application {
  final String id;
  final User client;
  final User adviser;
  final String consultationId;
  final String visaType;
  final String stage;
  final int progress;
  final List<TimelineEntry> timeline;
  final List<dynamic> deadlines; // Keep flexible until schema is defined
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Application({
    required this.id,
    required this.client,
    required this.adviser,
    required this.consultationId,
    required this.visaType,
    required this.stage,
    required this.progress,
    required this.timeline,
    required this.deadlines,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getters for UI
  String get displayVisaTypeTitle {
    final t = visaType.trim();
    if (t.isEmpty) return 'Visa Application';
    return "${t[0].toUpperCase()}${t.length > 1 ? t.substring(1) : ''} Application";
  }

  String get clientDisplayName {
    final n = client.fullName.trim();
    if (n.isNotEmpty) return n;
    if (client.email.trim().isNotEmpty) return client.email.trim();
    return 'Client';
  }

  TimelineEntry? get latestTimelineEntry {
    if (timeline.isEmpty) return null;
    // Prefer the entry with the latest non-null date; fallback to the last item
    TimelineEntry? latest = timeline.first;
    for (final e in timeline) {
      if (e.date == null) continue;
      if (latest?.date == null || (e.date!.isAfter(latest!.date!))) {
        latest = e;
      }
    }
    return latest;
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    final clientRaw = json['clientId'];
    final adviserRaw = json['adviserId'];

    return Application(
      id: (json['_id'] ?? '').toString(),
      client: User.fromJson(
        clientRaw is Map<String, dynamic> ? clientRaw : <String, dynamic>{},
      ),
      adviser: User.fromJson(
        adviserRaw is Map<String, dynamic> ? adviserRaw : <String, dynamic>{},
      ),
      consultationId: (json['consultationId'] ?? '').toString(),
      visaType: (json['visaType'] ?? '').toString(),
      stage: (json['stage'] ?? '').toString(),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      timeline: ((json['timeline'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TimelineEntry.fromJson)
          .toList(),
      deadlines: (json['deadlines'] as List?) ?? const [],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clientId': client.toJson(),
      'adviserId': adviser.toJson(),
      'consultationId': consultationId,
      'visaType': visaType,
      'stage': stage,
      'progress': progress,
      'timeline': timeline.map((t) => t.toJson()).toList(),
      'deadlines': deadlines,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Application.empty() {
    return Application(
      id: '',
      client: User.empty(),
      adviser: User.empty(),
      consultationId: '',
      visaType: '',
      stage: '',
      progress: 0,
      timeline: const [],
      deadlines: const [],
      createdAt: null,
      updatedAt: null,
    );
  }
}

class TimelineEntry {
  final String id;
  final String stage;
  final DateTime? date;
  final String? notes;
  final String? updatedBy;

  TimelineEntry({
    required this.id,
    required this.stage,
    this.date,
    this.notes,
    this.updatedBy,
  });

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      id: (json['_id'] ?? '').toString(),
      stage: (json['stage'] ?? '').toString(),
      date: _parseDate(json['date']),
      notes: (json['notes'] ?? '').toString().isEmpty ? null : (json['notes'] as String),
      updatedBy: (json['updatedBy'] ?? '').toString().isEmpty ? null : (json['updatedBy'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'stage': stage,
      'date': date?.toIso8601String(),
      'notes': notes,
      'updatedBy': updatedBy,
    };
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

// Helper to parse the entire response list (from a JSON string)
List<Application> parseApplications(String jsonString) {
  final data = json.decode(jsonString);
  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(Application.fromJson)
        .toList();
  }
  throw const FormatException('Expected a JSON array for cases');
}