import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/class_deadlines.dart';

class DeadlineCard extends StatelessWidget {
  final DueDeadline deadline;

  const DeadlineCard({super.key, required this.deadline});

  @override
  Widget build(BuildContext context) {
    final d = deadline.deadline;

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon
            CircleAvatar(
              backgroundColor: deadline.overdue ? Colors.red[100] : Colors.blue[100],
              child: Icon(
                deadline.overdue ? Icons.warning : Icons.event,
                color: deadline.overdue ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Visa type: ${deadline.visaType}"),
                  Text("Stage: ${deadline.stage}"),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Due: ${DateFormat.yMMMd().format(d.dueDate)}",
                        style: TextStyle(
                          color: deadline.overdue ? Colors.red : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        deadline.overdue
                            ? "Overdue"
                            : "${deadline.daysRemaining} days left",
                        style: TextStyle(
                          color: deadline.overdue ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
