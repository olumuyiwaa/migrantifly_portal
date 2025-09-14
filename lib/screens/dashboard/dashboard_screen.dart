import 'package:flutter/material.dart';

import '../../api/api_get.dart';
import '../../components/analytics_dashboards.dart';
import '../../components/user_list_table.dart';
import '../../components/stat_cards.dart';
import '../../components/users_jobs_breakdown.dart';
import '../../constants.dart';
import '../../models/class_business.dart';
import '../../models/class_countries.dart';
import '../../models/class_applications.dart';
import '../../models/class_users.dart';
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
   List<Country> allCountries = [];
   List<Business> allBusinesses = [];
  Future<void> _fetchAllData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      allUsers = await loadCachedUsers();
      allEvents = await loadCachedEvents();
      allCountries = await loadCachedCountries();
      allBusinesses = await loadCachedBusinesses();
      if (mounted && allUsers.isNotEmpty && allEvents.isNotEmpty && allCountries.isNotEmpty && allBusinesses.isNotEmpty) {
        setState(() {});
      }
      final freshUsers = await fetchUsers();
      await cacheUsers(freshUsers);
      final freshEvents = await getFeaturedEvents();
      await cacheEvents(freshEvents);
      final freshCountries = await getCountries();
      await cacheCountries(freshCountries);
      final freshBusinesses = await fetchBusinesses();
      await cacheBusinesses(freshBusinesses);

      if (mounted) {
        setState(() {
          allUsers = freshUsers;
          allEvents = freshEvents;
          allCountries = freshCountries;
          allBusinesses = freshBusinesses;
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
                    height: 692,
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
                    }, users: allUsers, events: allEvents, countries: allCountries, businesses: allBusinesses,
                  ),
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
            flex: 2,
            child: Column(
              children: [
                StatCards(
                  onItemTapped: (int index) {
                    widget.onItemTapped(index);
                  },
                  onTitleTapped: (String title) {
                    widget.onTitleTapped(title);
                  }, users: allUsers, events: allEvents, countries: allCountries, businesses: allBusinesses,
                ),
                UsersBreakdown(users: allUsers,)
              ],
            ),
          ),
      ],
    ));
  }
}
