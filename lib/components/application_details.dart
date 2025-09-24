// dart
import 'package:Migrantifly/models/class_documents.dart';
import 'package:flutter/material.dart';

import '../api/api_delete.dart';
import '../api/api_get.dart';
import '../constants.dart';
import '../models/class_applications.dart';
import '../models/class_users.dart';
import 'document_checklist_widget.dart';

class ApplicationDetailsPreviewModal extends StatefulWidget {
  final Application application;

  const ApplicationDetailsPreviewModal({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailsPreviewModal> createState() =>
      _ApplicationDetailsPreviewModalState();
}

void _showEditApplicationFormModal(BuildContext context, Application application) {
  // TODO: Replace with Application edit form when ready.
  // Keeping a placeholder dialog to avoid runtime issues.
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Edit Application"),
        content: const Text("Replace this with your Application edit form."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close")),
        ],
      );
    },
  );
}

Future<void> _showDeleteApplicationFormModal(BuildContext context, Application application) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final titleLine = "${application.clientDisplayName} • ${application.displayVisaTypeTitle}";
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text("Delete: $titleLine"),
        content: const Text(
          "Are you sure you want to delete this application?",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              // TODO: Implement removeApplication API. The current call targets events.
              // Example:
              // removeApplication(context: context, applicationID: application.id);
              removeApplication(
                context: context,
                applicationID: application.id,
              );
            },
          ),
        ],
      );
    },
  );
}

class _ApplicationDetailsPreviewModalState extends State<ApplicationDetailsPreviewModal> {
  List<User> selectedStaffs = [];
  List<User> filteredStaffs = [];
  List<Document> documents = [];
  bool _isSearching = false;
  bool _isLoadingDocuments = false;
  TextEditingController staffInputController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    if (mounted) setState(() => _isLoadingDocuments = true);
    try {
      // Load cached data first
      documents = await fetchApplicationDocuments(widget.application.id);
      if (mounted && documents.isNotEmpty) {
        setState(() {});
        setState(() => _isLoadingDocuments = false);
      }
    } catch (e) {
      debugPrint('Error fetching documents: $e');
      if (mounted) {
        setState(() => _isLoadingDocuments = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, app),
              const SizedBox(height: 20),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(spacing: defaultPadding,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Expanded(child:_buildSection('Application Details', [
                        _buildDetailItem(Icons.description, 'Visa Type', _nonEmpty(app.visaType)),
                        _buildDetailItem(Icons.flag, 'Stage', _nonEmpty(app.stage)),
                        _buildDetailItem(Icons.trending_up, 'Progress', "${app.progress}%"),
                        _buildDetailItem(Icons.confirmation_number, 'Consultation ID', _nonEmpty(app.consultationId)),
                      ])),
                      Expanded(child:_buildSection('Adviser', [
                        _buildDetailItem(Icons.person_outline, 'Name', _nonEmpty(app.adviser.fullName)),
                        _buildDetailItem(Icons.email_outlined, 'Email', _nonEmpty(app.adviser.email)),
                        _buildDetailItem(Icons.phone_outlined, 'Phone', _nonEmpty(app.adviser.phoneNumber)),
                        _buildDetailItem(Icons.location_on, 'Location', _nonEmpty(app.adviser.countryLocated)),
                      ])),]),
                    const Divider(height: 30),
                    Row(spacing: defaultPadding,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Expanded(child:_buildSection('Key Dates', [
                        _buildDetailItem(Icons.calendar_today, 'Created', _fmt(app.createdAt)),
                        _buildDetailItem(Icons.update, 'Last Updated', _fmt(app.updatedAt)),
                        _buildDetailItem(Icons.timeline, 'Latest Timeline Stage', _nonEmpty(app.latestTimelineEntry?.stage)),
                        _buildDetailItem(Icons.event_note, 'Latest Timeline Date', _fmt(app.latestTimelineEntry?.date)),
                        if ((app.latestTimelineEntry?.notes ?? '').isNotEmpty)
                          _buildDetailItem(Icons.notes, 'Latest Notes', app.latestTimelineEntry!.notes!),
                      ])),
                      Expanded(child:_buildSection('Required Documents', [ DocumentChecklistWidget(
                        visaType: app.visaType,
                      )])),]),
                    const Divider(height: 30),
                    Row(children: [Expanded(child: _buildSection('Client', [
                      _buildDetailItem(Icons.person, 'Name', _nonEmpty(app.client.fullName)),
                      _buildDetailItem(Icons.email, 'Email', _nonEmpty(app.client.email)),
                      _buildDetailItem(Icons.phone, 'Phone', _nonEmpty(app.client.phoneNumber)),
                      _buildDetailItem(Icons.location_on, 'Location', _nonEmpty(app.client.countryLocated)),
                      _buildDetailItem(Icons.home, 'Address', _nonEmpty(app.client.fullAddress)),
                    ])),
                      Container(
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.only(left: defaultPadding),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildAvatarOrImage(app.client.image),
                        ),
                      ),]),
                    if (documents.isNotEmpty)
                      Column(children: [
                        const Divider(height: 30),
                        Text(
                          "Documents",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(height: 80,child: ListView.builder(
                          padding: EdgeInsets.all(12),
                          itemCount: documents.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            final document = documents[index];
                            return _buildDetailItem(Icons.file_open, 'Document', _nonEmpty(document.name));
                          },
                        ),)])
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOrImage(String img) {
    // Prefer image if available; otherwise show an icon placeholder.
    if (img.isNotEmpty) {
      return Image.network(img, height: 372, width: double.infinity, fit: BoxFit.cover);
    }
    return Container(
      height: 372,
      width: double.infinity,
      color: Colors.blueGrey.shade100,
      child: const Icon(Icons.person, size: 96, color: Colors.white70),
    );
  }

  String _nonEmpty(String? v, [String placeholder = '—']) {
    final s = (v ?? '').trim();
    return s.isEmpty ? placeholder : s;
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return "$y-$m-$d $hh:$mm";
  }

  Widget _buildHeader(BuildContext context, Application app) {
    final subtitle = "${app.clientDisplayName} • ${app.displayVisaTypeTitle}";
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assignment,
              color: Colors.grey.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteApplicationFormModal(context, widget.application);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditApplicationFormModal(context, widget.application);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}