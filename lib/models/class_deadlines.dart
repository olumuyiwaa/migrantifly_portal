class DueDeadline {
  final String id;
  final String clientId;
  final String adviserId;
  final String visaType;
  final String stage;
  final bool overdue;
  final int daysRemaining;
  final String applicationId;
  final DeadlineInfo deadline;

  DueDeadline({
    required this.id,
    required this.clientId,
    required this.adviserId,
    required this.visaType,
    required this.stage,
    required this.overdue,
    required this.daysRemaining,
    required this.applicationId,
    required this.deadline,
  });

  factory DueDeadline.fromJson(Map<String, dynamic> json) {
    return DueDeadline(
      id: json['_id'],
      clientId: json['clientId'],
      adviserId: json['adviserId'],
      visaType: json['visaType'],
      stage: json['stage'],
      overdue: json['overdue'],
      daysRemaining: json['daysRemaining'],
      applicationId: json['applicationId'],
      deadline: DeadlineInfo.fromJson(json['deadline']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clientId': clientId,
      'adviserId': adviserId,
      'visaType': visaType,
      'stage': stage,
      'overdue': overdue,
      'daysRemaining': daysRemaining,
      'applicationId': applicationId,
      'deadline': deadline.toJson(),
    };
  }
}

class DeadlineInfo {
  final String type;
  final String description;
  final DateTime dueDate;
  final bool completed;
  final String id;

  DeadlineInfo({
    required this.type,
    required this.description,
    required this.dueDate,
    required this.completed,
    required this.id,
  });

  factory DeadlineInfo.fromJson(Map<String, dynamic> json) {
    return DeadlineInfo(
      type: json['type'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      completed: json['completed'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'completed': completed,
      '_id': id,
    };
  }
}

class DeadlinesSummary {
  final int total;
  final int overdue;
  final int dueToday;
  final int dueSoon;

  DeadlinesSummary({
    required this.total,
    required this.overdue,
    required this.dueToday,
    required this.dueSoon,
  });

  factory DeadlinesSummary.fromJson(Map<String, dynamic> json) {
    return DeadlinesSummary(
      total: json['total'],
      overdue: json['overdue'],
      dueToday: json['dueToday'],
      dueSoon: json['dueSoon'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'overdue': overdue,
      'dueToday': dueToday,
      'dueSoon': dueSoon,
    };
  }
}

class DeadlinesResponse {
  final List<DueDeadline> deadlines;
  final DeadlinesSummary summary;
  final int totalPages;

  DeadlinesResponse({
    required this.deadlines,
    required this.summary,
    required this.totalPages,
  });
}