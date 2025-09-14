import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/class_users.dart';

class Chart extends StatelessWidget {
  final List<User> users;

  const Chart({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 120,
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
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
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
    );
  }

  List<PieChartSectionData> _generateSections(List<User> users) {
    final ambassadorCount = users.where((user) => user.role == "adviser").length.toDouble();
    final artistCount = users.where((user) => user.role == "artist").length.toDouble();
    final adminCount = users
        .where((user) => user.role == "admin")
        .length
        .toDouble();
    final guestCount = users.where((user) => user.role == "client").length.toDouble();

    return [
      PieChartSectionData(
        title: "Advisers",
        color: primaryColor,
        value: ambassadorCount,
        showTitle: false,
        radius: 28,
      ),
      PieChartSectionData(
        title: "Groups/Entities",
        color: const Color(0xFF26E5FF),
        value: artistCount,
        showTitle: false,
        radius: 24,
      ),
      PieChartSectionData(
        title: "Admins",
        color: const Color(0xFFFFCF26),
        value: adminCount,
        showTitle: false,
        radius: 20,
      ),
      PieChartSectionData(
        title: "Clients",
        color: const Color(0xFFEE2727),
        value: guestCount,
        showTitle: false,
        radius: 16,
      ),
    ];
  }
}
