import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/class_applications.dart';
import 'document_checklist_widget.dart';

class  ApplicationCard extends StatefulWidget {
  final Application application;

  const  ApplicationCard({super.key, required this.application});

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> {
   bool clicked =false;
  @override
  Widget build(BuildContext context) {
    final stageColor = _getStatusColor(widget.application.stage);

    return !clicked ?
    Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        elevation: 3,
        child: ListTile(
          isThreeLine: true,
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15),borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.file_present_rounded,
                color: Colors.grey,
                size: 32,
              ),
            ),
      title: Row(
        children: [
          Chip(
            label: Text("${widget.application.visaType} visa"),
            backgroundColor: stageColor.withOpacity(0.15),
            labelStyle: TextStyle(
              color: stageColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8,),
          Text(
            "${widget.application.progress}%",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

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
          )
          ,          const SizedBox(height: 12),

        ],),
      onTap: (){
        setState(() {
          clicked = true;
        });
    },)) : GestureDetector(
        onTap: (){
          setState(() {
            clicked = false;
          });
        },
        child:  Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 16,
          children: [
            ConstrainedBox(constraints: BoxConstraints(maxWidth: 1100),child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      ),
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
                  const SizedBox(height: 14),

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
                  Column(
                    children: widget.application.timeline
                        .map((event) => _timelineItem(event: event))
                        .toList(),
                  ),
                ],
              ),
            ),),
// DOCUMENT CHECKLIST
            SizedBox(
              width: 412,
              child: DocumentChecklistWidget(
                visaType: widget.application.visaType,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Color _getStatusColor(String stage) {
    switch (stage) {
      case 'consultation':
        return Colors.blue;
      case 'deposit_paid':
        return Colors.orange;
      case 'documents_completed':
        return Colors.green;
      case 'application_submitted':
        return Colors.purple;
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _timelineItem extends StatelessWidget {
  final TimelineEntry event;

  const _timelineItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}