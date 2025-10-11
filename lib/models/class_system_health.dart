class SystemHealth {
  final String database;
  final double uptime;
  final Map<String, dynamic> memory;
  final String timestamp;

  SystemHealth({
    required this.database,
    required this.uptime,
    required this.memory,
    required this.timestamp,
  });

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json; // allow direct data usage if passed
    return SystemHealth(
      database: data['database'] ?? 'unknown',
      uptime: (data['uptime'] ?? 0).toDouble(),
      memory: Map<String, dynamic>.from(data['memory'] ?? {}),
      timestamp: data['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "database": database,
    "uptime": uptime,
    "memory": memory,
    "timestamp": timestamp,
  };
}
