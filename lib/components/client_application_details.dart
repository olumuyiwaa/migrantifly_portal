import 'package:Migrantifly/components/uploaded_documents.dart';
import 'package:Migrantifly/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import '../models/class_applications.dart';
import '../models/class_users.dart';
import '../responsive.dart';
import 'document_checklist_widget.dart';

class ApplicationDetailsPage extends StatelessWidget {
  final Application application;

  const ApplicationDetailsPage({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Sticky header for web
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                application.displayVisaTypeTitle,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            leading: CloseButton(),
            actions: [
              // Web-specific actions
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () => _printApplication(context),
                tooltip: 'Print Application',
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Main content with responsive layout
          SliverPadding(
            padding: EdgeInsets.all(isWideScreen ? 32 : 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isWideScreen)
                  _buildWideScreenLayout(context)
                else
                  _buildNormalLayout(context),
              ]),
            ),
          ),
        ],
      ),
      // Web-specific floating action button
      floatingActionButton: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
        screenWidth > 600 ? FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.wallet),
          label: const Text('Make Payment'),
        ) : FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.wallet),
        ),screenWidth > 600 ? FloatingActionButton.extended(
          onPressed: () => _uploadDocument(context),
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Document'),
        ) : FloatingActionButton(
          onPressed: () => _uploadDocument(context),
          child: const Icon(Icons.upload_file),
        )
      ],),
    );
  }

  Widget _buildWideScreenLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column (60%)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 24),
              _buildProgressCard(context),
              const SizedBox(height: 24),
              _buildRequiredDocuments(context),
              const SizedBox(height: 24),
              _buildUploadedDocuments(context),
            ],
          ),
        ),
         SizedBox(width: defaultPadding),
        // Right column (40%)
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClientAdviserCard(context),
              const SizedBox(height: 12),
              if (application.deadlines.isNotEmpty)
                _buildDeadlinesCard(context),
              const SizedBox(height: 12),
              _buildApplicationDetailsCard(context),
              const SizedBox(height: 12),
              _buildTimelineCard(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNormalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(context),
        const SizedBox(height: 16),
        _buildProgressCard(context),
        const SizedBox(height: 16),
        _buildClientAdviserCard(context),
        const SizedBox(height: 16),
        _buildApplicationDetailsCard(context),
        const SizedBox(height: 16),
        if (application.deadlines.isNotEmpty)
          _buildDeadlinesCard(context),
        const SizedBox(height: 16),
          _buildTimelineCard(context),
        const SizedBox(height: 16),
        _buildRequiredDocuments(context),
        const SizedBox(height: 16),
        _buildUploadedDocuments(context),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getVisaTypeIcon(application.visaType),
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    application.displayVisaTypeTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!Responsive.isMobile(context))
                _buildStatusChip(application.outcome),
                if (application.hasActiveDeadlines && !Responsive.isMobile(context)) ...[
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _showDeadlinesDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${application.upcomingDeadlines.length} Deadlines',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (Responsive.isMobile(context))
              SizedBox(height: defaultPadding,),
            if (Responsive.isMobile(context))
              Row(
                spacing: defaultPadding,
                children: [
                  _buildStatusChip(application.outcome),
                  if (application.hasActiveDeadlines) ...[
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showDeadlinesDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              Text(
                                '${application.upcomingDeadlines.length} Deadlines',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),


            if (application.inzReference?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.confirmation_number, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'INZ Ref: ${application.inzReference}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => _copyToClipboard(context, application.inzReference!),
                    tooltip: 'Copy INZ Reference',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getProgressColor(application.progress).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${application.progress}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(application.progress),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: application.progress / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(application.progress),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getStageDisplayName(application.stage),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientAdviserCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildContactRow('Adviser', application.adviser),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String label, User user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          child: Text(
            user.fullName.isNotEmpty
                ? user.fullName[0].toUpperCase()
                : user.email.isNotEmpty
                ? user.email[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label: ${user.fullName.isNotEmpty ? user.fullName : 'Not assigned'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (user.email.isNotEmpty)
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        Material(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: user.email.isNotEmpty ? () => _launchEmail(user.email) : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.email,
                size: 20,
                color: user.email.isNotEmpty ? Colors.blue[700] : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationDetailsCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              spacing: 12,
              children: [
              _buildDetailItem('Visa Type', application.visaType.toUpperCase()),
              _buildDetailItem('Current Stage', _getStageDisplayName(application.stage)),
            ],),
            const SizedBox(height: 12),
            Row(
              spacing: 12,
              children: [
              _buildDetailItem('Created', _formatDate(application.createdAt!)),
              if (application.submissionDate != null)
                _buildDetailItem('Submitted', _formatDate(application.submissionDate!)),
            ],),
            const SizedBox(height: 12),
            Row(
              spacing: 12,
              children: [
              if (application.decisionDate != null)
                _buildDetailItem('Decision Date', _formatDate(application.decisionDate!)),
              if (application.outcome != null)
                _buildDetailItem('Outcome', application.displayOutcome),
            ],),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String details) {
    return Expanded(child:
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          details,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),);
  }

  // Enhanced deadline and timeline cards with better web styling
  Widget _buildDeadlinesCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deadlines',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (application.hasActiveDeadlines)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${application.upcomingDeadlines.length} Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ...application.deadlines.take(3).map((deadline) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDeadlineRow(deadline),
            )),
            if (application.deadlines.length > 3)
              TextButton.icon(
                onPressed: () => _showAllDeadlines(context),
                icon: const Icon(Icons.visibility),
                label: Text('View all ${application.deadlines.length} deadlines'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ...application.timeline.take(5).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTimelineEntry(entry),
            )),
            if (application.timeline.length > 5)
              TextButton.icon(
                onPressed: () => _showFullTimeline(context),
                icon: const Icon(Icons.timeline),
                label: Text('View full timeline (${application.timeline.length} entries)'),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildRequiredDocuments(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            DocumentChecklistWidget(
              visaType: application.visaType,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedDocuments(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uploaded Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            UploadedDocument(
              applicationId: application.id,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineRow(Deadline deadline) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: deadline.completed
            ? Colors.green[50]
            : deadline.isOverdue
            ? Colors.red[50]
            : deadline.isDueSoon
            ? Colors.orange[50]
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: deadline.completed
              ? Colors.green[200]!
              : deadline.isOverdue
              ? Colors.red[200]!
              : deadline.isDueSoon
              ? Colors.orange[200]!
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: deadline.completed
                  ? Colors.green[100]
                  : deadline.isOverdue
                  ? Colors.red[100]
                  : Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              deadline.completed
                  ? Icons.check_circle
                  : deadline.isOverdue
                  ? Icons.error
                  : Icons.schedule,
              size: 20,
              color: deadline.completed
                  ? Colors.green[600]
                  : deadline.isOverdue
                  ? Colors.red[600]
                  : Colors.orange[600],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.displayType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (deadline.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    deadline.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (deadline.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${_formatDate(deadline.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: deadline.isOverdue ? Colors.red[600] : Colors.grey[600],
                      fontWeight: deadline.isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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

  Widget _buildStatusChip(String? outcome) {
    Color color;
    String text;
    IconData icon;

    switch (outcome?.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        icon = Icons.check_circle;
        break;
      case 'declined':
        color = Colors.red;
        text = 'Declined';
        icon = Icons.cancel;
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.pending;
        break;
      default:
        color = Colors.grey;
        text = 'In Progress';
        icon = Icons.sync;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Web-optimized helper methods
  IconData _getVisaTypeIcon(String visaType) {
    switch (visaType.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'partner':
        return Icons.favorite;
      case 'student':
        return Icons.school;
      case 'residence':
        return Icons.home;
      case 'visitor':
        return Icons.flight;
      case 'business':
        return Icons.business;
      default:
        return Icons.description;
    }
  }

  Color _getProgressColor(int progress) {
    if (progress < 20) return Colors.red;
    if (progress < 50) return Colors.orange;
    if (progress < 70) return Colors.yellow;
    if (progress < 90) return Colors.green;
    return Colors.blue;
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

  // Web-specific methods
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Regarding Application: ${application.displayVisaTypeTitle}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Fallback: copy email to clipboard
      await Clipboard.setData(ClipboardData(text: email));
      // Show snackbar or notification
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text" to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareApplication(BuildContext context) {
    // Implement sharing functionality
    final shareText = 'Application: ${application.displayVisaTypeTitle}\n'
        'Client: ${application.clientDisplayName}\n'
        'Status: ${application.displayOutcome}\n'
        'Progress: ${application.progress}%';

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application details copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _printApplication(BuildContext context) {
    // Implement print functionality for web
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Application'),
        content: const Text('Print functionality would generate a PDF report of the application details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement actual print logic here
            },
            child: const Text('Print'),
          ),
        ],
      ),
    );
  }

  void _uploadDocument(BuildContext context) async {
    final List<String> documentTypes = [
      'passport',
      'photo',
      'job_offer',
      'employment_contract',
      'financial_records',
      'bank_statements',
      'police_clearance',
      'medical_certificate',
      'qualification_documents',
      'marriage_certificate',
      'birth_certificate',
      'other'
    ];

    String? selectedType;
    String? fileName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Upload Document'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_upload, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),

                    // Dropdown for selecting type
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Document Type",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedType,
                      items: documentTypes
                          .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type.capitalizeWords())))
                          .toList(),
                      onChanged: (value) => setState(() => selectedType = value),
                    ),
                    const SizedBox(height: 16),

                    // File preview
                    if (fileName != null)
                      Text("Selected file: $fileName",
                          style: const TextStyle(fontSize: 12)),
                    if (fileName == null)
                      const Text("No file chosen",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                if(Responsive.isMobile(context))
                  SizedBox(height: 8,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                    );
                    if (result != null) {
                      setState(() {
                        fileName = result.files.single.name;
                      });
                    }
                  },
                  child: const Text('Choose File'),
                ),
                if(Responsive.isMobile(context))
                  SizedBox(height: 8,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: selectedType != null && fileName != null
                      ? () {
                    // TODO: upload logic (send file + type to backend)
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Document uploaded successfully!")),
                    );
                  }
                      : null,
                  child:  Text('Upload',style: TextStyle(color: selectedType != null && fileName != null
                      ? Colors.white : Colors.grey),),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showDeadlinesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Deadlines',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: application.upcomingDeadlines.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDeadlineRow(application.upcomingDeadlines[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showAllDeadlines(context);
                    },
                    child: const Text('View All Deadlines'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllDeadlines(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('All Deadlines'),
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  // Add new deadline functionality
                },
                icon: const Icon(Icons.add),
                tooltip: 'Add Deadline',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deadlines for ${application.displayVisaTypeTitle}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: application.deadlines.length,
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
                          child: _buildDeadlineRow(application.deadlines[index]),
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

  void _showFullTimeline(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Full Timeline'),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeline for ${application.displayVisaTypeTitle}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: application.timeline.length,
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
                          child: _buildTimelineEntry(application.timeline[index]),
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
}
extension StringCasingExtension on String {
  String capitalizeWords() {
    return split("_")
        .map((word) =>
    word.isNotEmpty ? "${word[0].toUpperCase()}${word.substring(1)}" : "")
        .join(" ");
  }
}