class DashboardStats {
  final OverviewStats overview;
  final Map<String, int> applicationsByStage;
  final Map<String, int> applicationsByVisaType;

  DashboardStats({
    required this.overview,
    required this.applicationsByStage,
    required this.applicationsByVisaType,
  });

  factory DashboardStats.fromResponse(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return DashboardStats(
      overview: OverviewStats.fromJson(data['overview'] as Map<String, dynamic>? ?? const {}),
      applicationsByStage: _mapToCountMap(data['applicationsByStage']),
      applicationsByVisaType: _mapToCountMap(data['applicationsByVisaType']),
    );
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      overview: OverviewStats.fromJson(json['overview'] ?? const {}),
      applicationsByStage: Map<String, int>.from(json['applicationsByStage'] ?? {}),
      applicationsByVisaType: Map<String, int>.from(json['applicationsByVisaType'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overview': overview.toJson(),
      'applicationsByStage': applicationsByStage,
      'applicationsByVisaType': applicationsByVisaType,
    };
  }

  static Map<String, int> _mapToCountMap(dynamic source) {
    if (source is Map) {
      return source.map((key, value) => MapEntry(key.toString(), _toInt(value)));
    }
    return {};
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class OverviewStats {
  final int totalApplications;
  final int activeClients;
  final int pendingConsultations;
  final int pendingDocuments;
  final int totalRevenue;

  const OverviewStats({
    required this.totalApplications,
    required this.activeClients,
    required this.pendingConsultations,
    required this.pendingDocuments,
    required this.totalRevenue,
  });

  factory OverviewStats.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return OverviewStats(
      totalApplications: toInt(json['totalApplications']),
      activeClients: toInt(json['activeClients']),
      pendingConsultations: toInt(json['pendingConsultations']),
      pendingDocuments: toInt(json['pendingDocuments']),
      totalRevenue: toInt(json['totalRevenue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalApplications': totalApplications,
      'activeClients': activeClients,
      'pendingConsultations': pendingConsultations,
      'pendingDocuments': pendingDocuments,
      'totalRevenue': totalRevenue,
    };
  }
}
