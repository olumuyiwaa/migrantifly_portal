import 'package:flutter/material.dart';

import '../../components/application_list_table.dart';
import '../../components/user_info_preview.dart';
import '../../constants.dart';
import '../../models/class_users.dart';
import '../../models/project.dart';

void _handleFilterChange(List<String> statuses, List<String> industries) {
  // Handle filter changes
  print('Selected statuses: $statuses');
  print('Selected industry: $industries');
  // You would typically use this to filter your data
}

class UserDetails extends StatefulWidget {
  final User user;
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  final int previousPageIndex;
  final String previousPageTitle;
  UserDetails(
      {super.key,
      required this.user, required this.onItemTapped, required this.onTitleTapped, required this.previousPageIndex, required this.previousPageTitle,});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
// Controllers for text fields

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(spacing: defaultPadding,crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [BackButton(onPressed: (){
            widget.onItemTapped(widget.previousPageIndex);
            widget.onTitleTapped(widget.previousPageTitle);},),Text("Back")],),UserInfoPreview(
        user: widget.user,
      ),
      SizedBox(
          height: 692,
          child: ApplicationListTable(
            userID: widget.user.id, filter: [],
          ))
    ]));
  }
}
