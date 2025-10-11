import 'package:flutter/material.dart';

import '../api/api_get.dart';
import '../constants.dart';
import '../models/class_system_health.dart';
import '../models/dashboard_stats.dart';

class StatCards extends StatelessWidget {
  final DashboardStats? stats;
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;

  const StatCards({
    super.key,
    required this.stats,
    required this.onItemTapped,
    required this.onTitleTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null){
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),height:580,child: Center(child: CircularProgressIndicator(),),);
    }
    else {
      final overview = stats!.overview;
    return GridView.count(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: .89,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          title: 'Active Clients',
          value: overview.activeClients.toString(),
          color: Colors.green,
          onTap: () {
            onItemTapped(1);
            onTitleTapped("Users");
          },
        ),
        StatCard(
          title: 'Total Applications',
          value: overview.totalApplications.toString(),
          color: Colors.deepPurple,
          onTap: () {
            onItemTapped(2);
            onTitleTapped("Applications");
          },
        ),

        StatCard(
          title: 'Pending Consultations',
          value: overview.pendingConsultations.toString(),
          color: Colors.orange,
          onTap: () {
            onItemTapped(4);
            onTitleTapped("Consultations");
          },
        ),
        StatCard(
          title: 'Pending Documents',
          value: overview.pendingDocuments.toString(),
          color: Colors.lightBlue,
          onTap: () {
            onItemTapped(5);
            onTitleTapped("Documents");
          },
        ),
        StatCard(
          title: 'Total Revenue',
          value: overview.totalRevenue.toString(),
          color: Colors.indigo,
          onTap: () {
            onItemTapped(8);
            onTitleTapped("Transactions");
          },
        ),
        SystemHealthCard(),
      ],
    );
  }}
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              )),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(title.contains("Revenue")? "\$ $value":value,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ))
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text("View All"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SystemHealthCard extends StatefulWidget {
  const SystemHealthCard({super.key});

  @override
  State<SystemHealthCard> createState() => _SystemHealthCardState();
}

class _SystemHealthCardState extends State<SystemHealthCard> {
  SystemHealth? _health;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHealth();
  }

  Future<void> _loadHealth() async {
  if (mounted) setState(() => _loading = true);
  try {
    _health = await loadCachedSystemHealth();
    if (mounted && _health != null) {
      setState(() {});
    }
    final freshHealth = await fetchSystemHealth();
    await cacheSystemHealth(freshHealth!);

    if (mounted) {
      setState(() {
        _health = freshHealth;
        _loading = false;
      });
    }
  } catch (e) {
    debugPrint('Error loading users: $e');
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
        : _health == null
        ? const Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("Failed to load system health"),
      ),
    )
        : Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueGrey[800],
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 2),
          )
        ],
      ),
      child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "System Health",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                )),
                GestureDetector(onTap: _loadHealth, child: Icon(Icons.refresh,color: Colors.white,))
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Database:", style: TextStyle(color: Colors.white70,fontSize: 12)),
                Text(
                  _health!.database,
                  style: TextStyle(
                    color: _health!.database == "connected"
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,fontSize: 12
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Uptime (s):", style: TextStyle(color: Colors.white70,fontSize: 12)),
                Text(
                  _health!.uptime.toStringAsFixed(2),
                  style: const TextStyle(color: Colors.white,fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Heap Used:", style: TextStyle(color: Colors.white70,fontSize: 12)),
                Text(
                  "${(_health!.memory['heapUsed'] / (1024 * 1024)).toStringAsFixed(2)} MB",
                  style: const TextStyle(color: Colors.white,fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("External:", style: TextStyle(color: Colors.white70,fontSize: 12)),
                Text(
                  "${(_health!.memory['external'] / (1024 * 1024)).toStringAsFixed(2)} MB",
                  style: const TextStyle(color: Colors.white,fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Updated: ${_health!.timestamp}",
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
    );
  }
}