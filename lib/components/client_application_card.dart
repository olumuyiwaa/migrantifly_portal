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
                    Row(
                      children: [
                        Text(
                          "Timeline",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Spacer(),
                        if (widget.application.timeline.length > 5)
                          TextButton.icon(
                            onPressed: () => _showFullTimeline(context),
                            icon: const Icon(Icons.timeline,color: Colors.blue,),
                            label: Text('View full timeline (${widget.application.timeline.length} entries)',style: TextStyle(color: Colors.blue),),
                          )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,runSpacing: 8,
                      children: widget.application.timeline.take(4)
                          .map((event) => _timelineItem(event: event))
                          .toList(),
                    ),
                  ],
                ),
                if (!Responsive.isMobile(context))
                Divider(),
// DOCUMENT CHECKLIST
                if (!Responsive.isMobile(context))
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
  void _showFullTimeline(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: CloseButton(),
            title: const Text('Full Timeline'),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeline for ${widget.application.displayVisaTypeTitle}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.application.timeline.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildTimelineEntry(widget.application.timeline[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTimelineEntry(TimelineEntry entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStageDisplayName(entry.stage),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (entry.date != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(entry.date!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (entry.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Text(
                  entry.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getStageDisplayName(String stage) {
    switch (stage.toLowerCase()) {
      case 'consultation':
        return 'Initial Consultation';
      case 'deposit_paid':
        return 'Deposit Paid';
      case 'documents_completed':
        return 'Documents Completed';
      case 'additional_docs_required':
        return 'Additional Documents Required';
      case 'submitted_to_inz':
        return 'Submitted to INZ';
      case 'inz_processing':
        return 'INZ Processing';
      case 'rfi_received':
        return 'Request for Information Received';
      case 'ppi_received':
        return 'Potentially Prejudicial Information Received';
      case 'decision':
        return 'Decision Made';
      default:
        return stage.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy at hh:mm a').format(date);
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
    return
      Responsive.isMobile(context)?Row(
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
                      maxLines: 4,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12,overflow: TextOverflow.ellipsis),
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
      ):
      ConstrainedBox(constraints: BoxConstraints(maxWidth:  220),child: Row(
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
                    maxLines: 4,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12,overflow: TextOverflow.ellipsis),
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