import 'package:Migrantifly/components/deadline_card.dart';
import 'package:Migrantifly/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_get.dart';
import '../../components/client_application_card.dart';
import '../../models/class_deadlines.dart';
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
  String greeting = "";
  String tagline = "";
  String username = "";
  IconData icon = Icons.sunny;
  var _deadlines =<DueDeadline>[];
  DeadlinesSummary? _summary;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    getUserInfo();
    _determineGreeting();
    loadDeadlines();
  }

  Future<void> loadDeadlines() async {
    try {
      final deadlines = await fetchDeadlines();
      setState(() {
        _deadlines = deadlines.deadlines;
        _summary = deadlines.summary;
      });

      // Optionally, force refresh in background
      fetchDeadlines(forceRefresh: true).then((fresh) {
        setState(() {
          _deadlines = fresh.deadlines;
          _summary = fresh.summary;
        });
      });
    } catch (e) {
      print("Error: $e");
    }
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

  void _determineGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour < 12) {
      greeting = "Morning";
      icon = Icons.wb_sunny;
      tagline = "Start your day with focus and energy!";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Afternoon";
      icon = Icons.wb_sunny_outlined;
      tagline = "Keep the momentum going — you’re doing great!";
    } else {
      greeting = "Evening";
      icon = Icons.nights_stay;
      tagline = "Wind down and review your progress for today.";
    }
  }


  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = "${prefs.getString('first_name')} ${prefs.getString('last_name')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return  Center(child: CircularProgressIndicator(color: Colors.blue,));
    }

    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child:  SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding:  EdgeInsets.all(Responsive.isMobile(context)?8:16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Icon(icon,size: 48,),
                  const SizedBox(width: 12),
                  Text(
                    "Good $greeting\n$username",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(tagline,style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),),
              const SizedBox(height: 14),
              _buildSummaryGrid(),
              const SizedBox(height: 28),
            Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: defaultPadding,
            children: [
            Expanded(
            flex: 2,
            child:Column(children:[_buildSectionHeader("My Applications", Icons.folder),
                  const SizedBox(height: 12),
                  ...dashboardData!.applications
                      .map((app) => ApplicationCard(application: app)),
                 ])),
                  if(!Responsive.isMobile(context))
                    Expanded(flex:1,child: SizedBox(child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if(dashboardData!.recentPayments.isEmpty)Container(
                            alignment: Alignment.center,
                            height: 100,child: Text("No Data Yet")),
                        _buildSectionHeader("Recent Payments", Icons.credit_card),
                        const SizedBox(height: 12),
                        ...dashboardData!.recentPayments
                            .map((p) => ModernPaymentCard(payment: p)),
                        const SizedBox(height: 28),
                        _buildSectionHeader("Deadlines", Icons.event),
                        const SizedBox(height: 12),
                        if(_deadlines.isEmpty)Container(
                            alignment: Alignment.center,
                            height: 100,child: Text("No Data Yet")),
                        ..._deadlines.map((deadline) => DeadlineCard(deadline: deadline)),
                      ],)))
                ],
              ),
              const SizedBox(height: 28),
              if(Responsive.isMobile(context))
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if(dashboardData!.recentPayments.isEmpty)Container(
                        alignment: Alignment.center,
                        height: 100,child: Text("No Data Yet")),
                    _buildSectionHeader("Recent Payments", Icons.credit_card),
                    const SizedBox(height: 12),
                    ...dashboardData!.recentPayments
                        .map((p) => ModernPaymentCard(payment: p)),
                    const SizedBox(height: 28),
                    _buildSectionHeader("Deadlines", Icons.event),
                    const SizedBox(height: 12),
                    if(_deadlines.isEmpty)Container(
                        alignment: Alignment.center,
                        height: 100,child: Text("No Data Yet")),
                    ..._deadlines.map((deadline) => DeadlineCard(deadline: deadline)),
                  ],)
            ],
          ),
        ));
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
      spacing: Responsive.isMobile(context)?(MediaQuery.of(context).size.width * 0.034):10,runSpacing: 12,
      children: items.map((item) {
        final (title, value, icon, color) = item;
        return SizedBox(
          width: Responsive.isMobile(context)?(MediaQuery.of(context).size.width * 0.415):(MediaQuery.of(context).size.width * 0.2),
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
        borderRadius: BorderRadius.circular(16),
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
