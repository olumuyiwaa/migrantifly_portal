import 'package:flutter/material.dart';

import '../constants.dart';
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
      ],
    );
  }}
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
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