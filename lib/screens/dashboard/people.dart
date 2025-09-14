import 'package:flutter/material.dart';

import '../../api/api_get.dart';
import '../../components/active_users.dart';
import '../../components/filter.dart';
import '../../components/user_list_table.dart';
import '../../constants.dart';
import '../../models/class_users.dart';
import '../../responsive.dart';

class People extends StatefulWidget {
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  final ValueChanged<User> onItemUser;

  People(
      {super.key,
      required this.onItemTapped,
      required this.onTitleTapped,
      required this.onItemUser,});

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {

  List<User>allUser=[];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }


  Future<void> _fetchAllUsers() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      allUser = await loadCachedUsers();
      if (mounted && allUser.isNotEmpty) {
        setState(() {});
      }
      final freshUsers = await fetchUsers();
      await cacheUsers(freshUsers);

      if (mounted) {
        setState(() {
          allUser = freshUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String>filter=[];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(spacing: defaultPadding, children: [
      ActivePeopleWidget(users: allUser,),
      Row(
        spacing: defaultPadding,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!Responsive.isMobile(context)) FilterWidget(
            onFiltersChanged: (selectedFilters) {
              setState(() {
                filter = selectedFilters;
                print('Selected filters are: $filter');
              });
            },
            users: allUser,),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                spacing: defaultPadding,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: 692,
                      child: UserListTable(
                        // allStaffs: allStaffs,
                        onItemTapped: (int index) {
                          widget.onItemTapped(index);
                        },
                        onTitleTapped: (String title) {
                          widget.onTitleTapped(title);
                        },
                        onItemUser: (User user) {
                          widget.onItemUser(user);
                        }, filter: filter,
                      )),
                  if (Responsive.isMobile(context)) FilterWidget(
                    onFiltersChanged: (selectedFilters) {
                      setState(() {
                        filter = selectedFilters;
                        print('Selected filters are: $filter');
                      });
                    },
                    users: allUser,),
                ],
              ),
            ),
          ),
        ],
      )
    ]));
  }
}
