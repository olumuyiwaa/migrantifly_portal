import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/class_users.dart';
import '../responsive.dart';

class UsersBreakdown extends StatelessWidget {
  final List<User> users;
  const UsersBreakdown({
    super.key, required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 12,
          ),
          Text(
            "Users Breakdown",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          Row(children: [
            Expanded(child: SizedBox(
              height: 320,
              width: 320,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 120, // smaller than any section radius
                      startDegreeOffset: -90,
                      sections: _generateSections(users),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: defaultPadding),
                        Text(
                          users.length.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            fontSize: 24,
                          ),
                        ),
                        const Text("Total"),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(width: defaultPadding),
            Column(
              spacing: 8,
              children: [
                RoleBox(count: users.where((user) => user.role == "client").length,label: "Clients",),
                RoleBox(count: users.where((user) => user.role == "adviser").length,label: "Advisers",),
                RoleBox(count: users.where((user) => user.role == "admin").length,label: "Admins",),
              ],
            ),            SizedBox(width: defaultPadding),
          ],)
        ],
      ),
    );
  }
}
class RoleBox extends StatelessWidget {
  final int count;
  final String label;

  const RoleBox({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF3361FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$count",
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
          ),
          Text(
            label[0].toUpperCase() + label.substring(1), // capitalize
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> _generateSections(List<User> users) {
  final advisers = users.where((u) => u.role == "adviser").length.toDouble();
  final artists  = users.where((u) => u.role == "artist").length.toDouble();
  final admins   = users.where((u) => u.role == "admin").length.toDouble();
  final clients  = users.where((u) => u.role == "client").length.toDouble();

  final total = advisers + artists + admins + clients;

  // Guard: when there's no data, draw a faint placeholder slice to avoid NaN/zero-division.
  if (total == 0) {
    return [
      PieChartSectionData(
        title: "No data",
        color: Colors.grey.shade300,
        value: 1,
        showTitle: false,
        radius: 10,
      ),
    ];
  }

  // Make sure section radii are larger than centerSpaceRadius so they are visible.
  return [
    PieChartSectionData(
      title: "Advisers",
      color: primaryColor,
      value: advisers,
      showTitle: false,
      radius: 14,
    ),
    PieChartSectionData(
      title: "Groups/Entities",
      color: const Color(0xFF26E5FF),
      value: artists,
      showTitle: false,
      radius: 12,
    ),
    PieChartSectionData(
      title: "Admins",
      color: const Color(0xFFFFCF26),
      value: admins,
      showTitle: false,
      radius: 11,
    ),
    PieChartSectionData(
      title: "Clients",
      color: const Color(0xFFEE2727),
      value: clients,
      showTitle: false,
      radius: 10,
    ),
  ];
}
