import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/class_applications.dart';
import '../responsive.dart';
import 'client_application_details.dart';
import 'document_checklist_widget.dart';

class  ApplicationCard extends StatefulWidget {
  final Application application;

  const  ApplicationCard({super.key, required this.application});

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}
void _showApplicationDetailsModal(BuildContext context, Application app) {
  final width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          width: width *(Responsive.isDesktop(context)? 0.7:0.9),
          height: MediaQuery.of(context).size.height * 0.9,
          child: ApplicationDetailsPage(
            application: app,
          ),
        ),
      );
    },
  );
}
class _ApplicationCardState extends State<ApplicationCard> {
  @override
  Widget build(BuildContext context) {
    final stageColor = _getStatusColor(widget.application.progress);

    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children:[

// VISA TYPE + PROGRESS
            Row(
              children: [
                Chip(
                  label: Text("${widget.application.visaType} visa"),
                  backgroundColor: stageColor.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: stageColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "${widget.application.progress}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),SizedBox(width: 12,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _showApplicationDetailsModal(context, widget.application);
                  },
                  child: const Text("Full Details",style: TextStyle(color: Colors.white),),
                )

              ],
            ),
            const SizedBox(height: 12),

// PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.application.progress / 100),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(stageColor),
                ),
              ),
            ),
            const SizedBox(height: 14),Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
// STATUS
                    Text(
                      "Status: ${widget.application.stage}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

// ADVISER
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.application.adviser.fullName,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

// TIMELINE
                    const Text(
                      "Timeline",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      children: widget.application.timeline
                          .map((event) => _timelineItem(event: event))
                          .toList(),
                    ),
                  ],
                ),
                Divider(),
// DOCUMENT CHECKLIST
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 8),child: Text(
                      "Required Documents",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
                    const SizedBox(height: 10),
                    DocumentChecklistWidget(
                      visaType: widget.application.visaType,
                    )
                  ],),
              ],
            ),
          ]),
        ));
  }

  Color _getStatusColor(int progress) {
    if (progress < 20) return Colors.red;
    if (progress < 50) return Colors.orange;
    if (progress < 70) return Colors.yellow;
    if (progress < 90) return Colors.green;
    return Colors.blue;
  }
}

class _timelineItem extends StatelessWidget {
  final TimelineEntry event;

  const _timelineItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(constraints: BoxConstraints(maxWidth: 240),child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// vertical line with dot
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: Colors.blue.withOpacity(0.4),
            ),
          ],
        ),
        const SizedBox(width: 10),

        /// text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.stage,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (event.notes != null)
                  Text(
                    event.notes!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                Text(
                  DateFormat("dd MMM yyyy").format(event.date!),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    ),);
  }
}