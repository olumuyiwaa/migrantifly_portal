import 'package:flutter/material.dart';

import '../../api/api_get.dart';
import '../../components/analytics_dashboards.dart';
import '../../components/stats_charts.dart';
import '../../components/user_list_table.dart';
import '../../components/stat_cards.dart';
import '../../components/users_jobs_breakdown.dart';
import '../../constants.dart';
import '../../models/class_consultation.dart';
import '../../models/class_applications.dart';
import '../../models/class_users.dart';
import '../../models/dashboard_stats.dart';
import '../../responsive.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  final ValueChanged<User> onItemUser;

  DashboardScreen({
    super.key,
    required this.onItemTapped,
    required this.onTitleTapped,
    required this.onItemUser, // Make sure to pass the callback from the parent
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }
  bool _isLoading=false;
   List<User> allUsers = [];
   List<Application> allEvents = [];
   DashboardStats? dashboardStats;
  Future<void> _fetchAllData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      allUsers = await loadCachedUsers();
      allEvents = await loadCachedApplications();
      dashboardStats = await loadCachedDashboardStats();
      if (mounted && allUsers.isNotEmpty && allEvents.isNotEmpty && dashboardStats != null) {
        setState(() {
          _isLoading = false;
        });
      }
      final freshUsers = await fetchUsers();
      await cacheUsers(freshUsers);
      final freshEvents = await getFeaturedApplications();
      await cacheApplications(freshEvents);
      final freshDashboardStats = await getDashboardStats();
      await cacheDashboardStats(freshDashboardStats);

      if (mounted) {
        setState(() {
          allUsers = freshUsers;
          allEvents = freshEvents;
          dashboardStats = freshDashboardStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnalyticsDashboard(),
                SizedBox(height: defaultPadding),
                SizedBox(
                    height: 652,
                    child: UserListTable(
                      onItemTapped: (int index) {
                        widget.onItemTapped(index);
                      },
                      onTitleTapped: (String title) {
                        widget.onTitleTapped(title);
                      },
                      onItemUser: (User value) {
                        widget.onItemUser(value);
                      }, filter: [],
                    )),
                if (Responsive.isMobile(context))
                  SizedBox(height: defaultPadding),
                if (Responsive.isMobile(context))
                  StatCards(
                    onItemTapped: (int index) {
                      widget.onItemTapped(index);
                    },
                    onTitleTapped: (String title) {
                      widget.onTitleTapped(title);
                    }, stats:dashboardStats,
                  ),
                if (Responsive.isMobile(context))
                  SizedBox(height: defaultPadding),
                if (Responsive.isMobile(context))
                StatsCharts(stats: dashboardStats),
                if (Responsive.isMobile(context))
                  SizedBox(height: defaultPadding),
                if (Responsive.isMobile(context)) UsersBreakdown(users: allUsers,),
              ],
            ),
          ),
        ),
        if (!Responsive.isMobile(context)) SizedBox(width: defaultPadding),
        // On Mobile means if the screen is less than 850 we don't want to show it
        if (!Responsive.isMobile(context))
          Expanded(
            flex: 3,
            child: Column(
              children: [
                StatCards(
                  onItemTapped: (int index) {
                    widget.onItemTapped(index);
                  },
                  onTitleTapped: (String title) {
                    widget.onTitleTapped(title);
                  }, stats: dashboardStats,
                ),
                SizedBox(height: 12),
                // The charts
                StatsCharts(stats: dashboardStats),
                SizedBox(height: defaultPadding),
                UsersBreakdown(users: allUsers,)
              ],
            ),
          ),
      ],
    ));
  }
}
