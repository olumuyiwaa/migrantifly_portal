import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/class_users.dart';
import 'chart.dart';

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
          SizedBox(height: defaultPadding),
          Chart(users:users),
          SizedBox(height: defaultPadding),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3361FF).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        users.where((user) => user.role == "client").length.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 24),
                      ),
                      Text(
                        "Clients",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3361FF).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        users.where((user) => user.role == "adviser").length.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 24),
                      ),
                      Text(
                        "Advisers",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3361FF).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        users.where((user) => user.role == "admin").length.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 24),
                      ),
                      Text(
                        "Admins",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          // Row(
          //   spacing: 8,
          //   children: [
          //     Expanded(
          //       child: Container(
          //         height: 100,
          //         decoration: BoxDecoration(
          //           color: const Color(0xFF3361FF).withOpacity(0.05),
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child:  Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Text(
          //               users.where((user) => user.role == "artist").length.toString(),
          //               style: TextStyle(
          //                   fontWeight: FontWeight.w700, fontSize: 24),
          //             ),
          //             Text(
          //               "Entities/Groups",
          //               style: TextStyle(fontSize: 12),
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //     Expanded(
          //       child: Container(
          //         height: 100,
          //         decoration: BoxDecoration(
          //           color: const Color(0xFF3361FF).withOpacity(0.05),
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child:  Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Text(
          //               users.where((user) => user.role == "admin").length.toString(),
          //               style: TextStyle(
          //                   fontWeight: FontWeight.w700, fontSize: 24),
          //             ),
          //             Text(
          //               "Admins",
          //               style: TextStyle(fontSize: 12),
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
