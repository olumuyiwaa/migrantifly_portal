import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../api/api_get.dart';
import '../../components/client_application_card.dart';
import '../../components/document_checklist_widget.dart';
import '../../models/class_applications.dart';
import '../../models/client_dashboard_stats.dart';
import '../../responsive.dart';

class ClientDashboard extends StatefulWidget {
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;

  const ClientDashboard({
    super.key,
    required this.onItemTapped,
    required this.onTitleTapped,
  });

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  DashboardData? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => isLoading = true);

    try {
      dashboardData = await loadCachedClientDashboardStats();
      if (mounted && dashboardData != null) {
        setState(() {
          isLoading = false;
        });
      }
      final freshDashboardStats = await getClientDashboardStats();
      await cacheClientDashboardStats(freshDashboardStats);

      if (mounted) {
        setState(() {
          dashboardData = freshDashboardStats;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return  Center(child: CircularProgressIndicator(color: Colors.blue,));
    }

    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryGrid(),
            const SizedBox(height: 28),
            _buildSectionHeader("My Applications", Icons.folder),
            const SizedBox(height: 12),
            ...dashboardData!.applications
                .map((app) => ApplicationCard(application: app)),
            const SizedBox(height: 28),
            _buildSectionHeader("Recent Payments", Icons.credit_card),
            const SizedBox(height: 12),
            ...dashboardData!.recentPayments
                .map((p) => ModernPaymentCard(payment: p)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    final summary = dashboardData!.summary;
    final items = [
      ("Total Applications", summary.totalApplications.toString(), Icons.folder, Colors.blue),
      ("Active Applications", summary.activeApplications.toString(), Icons.work, Colors.green),
      ("Notifications", summary.unreadNotifications.toString(), Icons.notifications, Colors.orange),
      ("Deadlines", summary.pendingDeadlines.toString(), Icons.event, Colors.red),
    ];

    return Wrap(
      children: items.map((item) {
        final (title, value, icon, color) = item;
        return Container(
          padding: EdgeInsets.all(Responsive.isMobile(context)?6:12),
          width: Responsive.isMobile(context)?172:320,
          child: ModernSummaryCard(
            title: title,
            value: value,
            icon: icon,
            color: color,
          ),
        );
      }).toList(),
    );
  }


  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// --- MODERN CARDS --- ///

class ModernSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ModernSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.isMobile(context)?12:14,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernPaymentCard extends StatelessWidget {
  final Payment payment;

  const ModernPaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(payment.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(
            payment.status == "completed"
                ? Icons.check_circle
                : Icons.timelapse,
            color: statusColor,
            size: 26,
          ),
        ),
        title: Text(
          payment.formattedAmount,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "${payment.formattedType} • ${payment.invoiceNumber}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                payment.status.toUpperCase(),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor),
              ),
              backgroundColor: statusColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            Spacer(),
            Text(
              DateFormat("dd MMM yyyy").format(payment.createdAt),
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
