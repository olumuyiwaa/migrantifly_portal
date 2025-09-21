import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/header.dart';
import '../../components/side_menu.dart';
import '../../constants.dart';
import '../../controllers/menu_app_controller.dart';
import '../../models/class_users.dart';
import '../../responsive.dart';
import '../dashboard/administration.dart';
import '../dashboard/calender.dart';
import '../dashboard/documents.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/consultations.dart';
import '../dashboard/people.dart';
import '../dashboard/applications.dart';
import '../dashboard/transactions.dart';
import '../dashboard/user_details.dart';

class ActiveSession extends StatefulWidget {
  final int pageIndex;

  const ActiveSession({super.key, this.pageIndex = 0});
  @override
  State<ActiveSession> createState() => _ActiveSessionState();
}

class _ActiveSessionState extends State<ActiveSession> {
  int _pageIndex = 0;
  String _currentTitle = "Dashboard";
  User user = User.empty();
  int previousIndex = 0;
  String previousTitle = "Dashboard";
  String userImage = "";

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.pageIndex;
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userImage = prefs.getString('image') ?? '';
    });
  }

  void goToUserDetails({
    required int fromIndex,
    required String fromTitle,
    required User selectedUser,
  }) {
    setState(() {
      previousIndex = fromIndex;
      previousTitle = fromTitle;
      user = selectedUser;
      _pageIndex = 7; // Index for UserDetails
      _currentTitle = "User Details";
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> selectedPage = [
      DashboardScreen(
        onItemTapped: (int index) => setState(() => _pageIndex = index),
        onTitleTapped: (String title) => setState(() => _currentTitle = title),
        onItemUser: (User value) => goToUserDetails(
          fromIndex: 0,
          fromTitle: "Dashboard",
          selectedUser: value,
        ),
      ),
      People(
        onItemTapped: (int index) => setState(() => _pageIndex = index),
        onTitleTapped: (String title) => setState(() => _currentTitle = title),
        onItemUser: (User value) => goToUserDetails(
          fromIndex: 1,
          fromTitle: "Users",
          selectedUser: value,
        ),
      ),
      Events(),
      Calendar(),
      Consultations(),
      DocumentsWidget(),
      Administration(),
      UserDetails(
        user: user,
        onItemTapped: (int index) => setState(() => _pageIndex = index),
        onTitleTapped: (String title) => setState(() => _currentTitle = title),
        previousPageIndex: previousIndex,
        previousPageTitle: previousTitle,
      ),Transactions()
    ];

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(
        image:userImage,
        pageIndex: _pageIndex,
        onItemTapped: (int index) =>
            setState(() => _pageIndex = index.clamp(0, selectedPage.length - 1)),
        onTitleTapped: (String title) =>
            setState(() => _currentTitle = title),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              SizedBox(
                width: 256,
                child: SideMenu(
                  image:userImage,
                  pageIndex: _pageIndex,
                  onItemTapped: (int index) =>
                      setState(() => _pageIndex = index.clamp(0, selectedPage.length - 1)),
                  onTitleTapped: (String title) =>
                      setState(() => _currentTitle = title),
                ),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                primary: false,
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    Header(
                      title: _currentTitle,
                      onItemTapped: (int index) =>
                          setState(() => _pageIndex = index),
                      onTitleTapped: (String title) =>
                          setState(() => _currentTitle = title),
                    ),
                    SizedBox(height: defaultPadding),
                    selectedPage[_pageIndex.clamp(0, selectedPage.length - 1)],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
