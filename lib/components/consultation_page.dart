import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_delete.dart';
import '../api/api_get.dart';
import '../constants.dart';
import '../models/class_consultation.dart';
import '../models/class_applications.dart';
import '../models/class_users.dart';

class ConsultationPage extends StatefulWidget {
  final Consultation consultation;
  final Function() onChange;

  const ConsultationPage({
    super.key,
    required this.consultation,
    required this.onChange,
  });

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  String consultationType = "";
  String consultationNotes = "";
  String consultationMethod = "";
  String consultationStatus = "";
  int consultationDuration = 0;
  DateTime? scheduledDate;
  String clientName = "";
  String clientEmail = "";
  String clientPhone = "";
  String clientPhoto = "";
  String adviserName = "";
  String adviserEmail = "";
  String adviserPhone = "";
  String adviserPhoto = "";
  List<String> visaPathways = [];
  String clientToken = "";

  Consultation? consultationDetails;
  List<Consultation> relatedApplications = [];
  List<Consultation> allApplications = [];
  List<User> fetchedUsers = [];
  bool _isLoading = true;
  String userID = "";

  void _showEditConsultationFormModal(BuildContext context, Consultation consultation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            // child: ConsultationDetailsForm(
            //   consultation: consultation,
            //   isEditing: true,
            //   onSave: () {
            //     widget.onChange();
            //     _fetchConsultationDetails();
            //   },
            // ),
          ),
        );
      },
    );
  }

  Future<void> _fetchConsultationDetails() async {
    setState(() => _isLoading = true);
    try {
      final consultation = widget.consultation;
      final users = await fetchUsers();

      if (consultation == null) {
        debugPrint("Consultation details are null");
        setState(() => _isLoading = false);
        return;
      }

      // Fetch related applications
      final fetchedApplications = await fetchConsultations();
      final clientRelated = fetchedApplications.where((app) {
        return app.client.id == consultation.client.id;
      }).toList();

      // Update state safely
      setState(() {
        consultationDetails = consultation;
        fetchedUsers = users;
        consultationType = consultation.type;
        consultationNotes = consultation.notes;
        consultationMethod = consultation.method;
        consultationStatus = consultation.status;
        consultationDuration = consultation.duration;
        scheduledDate = consultation.scheduledDate;
        visaPathways = consultation.visaPathways;
        clientToken = consultation.clientToken;

        // Client details
        clientName = consultation.client.fullName;
        clientEmail = consultation.client.email;
        clientPhone = consultation.client.phoneNumber;
        clientPhoto = consultation.client.image;

        // Adviser details
        adviserName = consultation.adviser.fullName;
        adviserEmail = consultation.adviser.email;
        adviserPhone = consultation.adviser.phoneNumber;
        adviserPhoto = consultation.adviser.image;

        allApplications = clientRelated;
        relatedApplications = allApplications;

        _isLoading = false;
      });
    } catch (error) {
      debugPrint("Error fetching consultation details: $error");
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchConsultationDetails().then((_) => getUserInfo());
  }

  @override
  void didUpdateWidget(ConsultationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consultation.id != widget.consultation.id) {
      _fetchConsultationDetails().then((_) => getUserInfo());
    }
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('id') ?? '';
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in-progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : consultationDetails == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Consultation Not Found"),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16),
                child: Text("Try Again"),
              ),
            )
          ],
        ),
      )
          : Column(
        children: [
          // Consultation header
          ConsultationHeader(
            consultationType: consultationType,
            consultationStatus: consultationStatus,
            onEdit: () {
              _showEditConsultationFormModal(context, widget.consultation);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ConsultationContent(
                consultationType: consultationType,
                consultationNotes: consultationNotes,
                consultationMethod: consultationMethod,
                consultationStatus: consultationStatus,
                consultationDuration: consultationDuration,
                scheduledDate: scheduledDate,
                clientName: clientName,
                clientEmail: clientEmail,
                clientPhone: clientPhone,
                clientPhoto: clientPhoto,
                adviserName: adviserName,
                adviserEmail: adviserEmail,
                adviserPhone: adviserPhone,
                adviserPhoto: adviserPhoto,
                visaPathways: visaPathways,
                clientToken: clientToken,
                relatedApplications: relatedApplications,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsultationHeader extends StatelessWidget {
  final String consultationType;
  final String consultationStatus;
  final VoidCallback onEdit;

  const ConsultationHeader({
    super.key,
    required this.consultationType,
    required this.consultationStatus,
    required this.onEdit,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in-progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Title and actions
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        consultationType.isNotEmpty ? consultationType : 'General Consultation',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(consultationStatus),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          consultationStatus.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Action button
                if (!consultationStatus.toLowerCase().contains("complete"))
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.fact_check, color: Colors.green[600]),
                  tooltip: "Complete",
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Status info bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    "This page shows the details of the consultation session.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsultationContent extends StatelessWidget {
  final String consultationType;
  final String consultationNotes;
  final String consultationMethod;
  final String consultationStatus;
  final int consultationDuration;
  final DateTime? scheduledDate;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String clientPhoto;
  final String adviserName;
  final String adviserEmail;
  final String adviserPhone;
  final String adviserPhoto;
  final List<String> visaPathways;
  final String clientToken;
  final List<Consultation> relatedApplications;

  const ConsultationContent({
    super.key,
    required this.consultationType,
    required this.consultationNotes,
    required this.consultationMethod,
    required this.consultationStatus,
    required this.consultationDuration,
    required this.scheduledDate,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.clientPhoto,
    required this.adviserName,
    required this.adviserEmail,
    required this.adviserPhone,
    required this.adviserPhoto,
    required this.visaPathways,
    required this.clientToken,
    required this.relatedApplications,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content area (left side)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Session Details Section
                ConsultationSection(
                  title: "Session Details",
                  content: consultationNotes.isNotEmpty
                      ? consultationNotes
                      : "No additional notes for this consultation.",
                ),
                const SizedBox(height: 24),

                // Visa Pathways Section
                if (visaPathways.isNotEmpty)
                  ConsultationSection(
                    title: "Visa Pathways Discussed",
                    content: visaPathways.join(', '),
                  ),
                const SizedBox(height: 24),

                // Related Applications Section
                if (relatedApplications.isNotEmpty)
                  ConsultationApplicationsSection(applications: relatedApplications),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Sidebar (right side)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ConsultationInfoBox(
                  consultationType: consultationType,
                  consultationMethod: consultationMethod,
                  consultationDuration: consultationDuration,
                  scheduledDate: scheduledDate,
                  clientToken: clientToken,
                ),

                const SizedBox(height: 24),

                // Client Info Section
                ConsultationPersonBox(
                  title: "Client Information",
                  name: clientName,
                  email: clientEmail,
                  phone: clientPhone,
                  photo: clientPhoto,
                ),

                const SizedBox(height: 24),

                // Adviser Info Section
                ConsultationPersonBox(
                  title: "Adviser Information",
                  name: adviserName,
                  email: adviserEmail,
                  phone: adviserPhone,
                  photo: adviserPhoto,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConsultationSection extends StatelessWidget {
  final String title;
  final String content;

  const ConsultationSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 2),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              fontFamily: 'Georgia',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class ConsultationInfoBox extends StatelessWidget {
  final String consultationType;
  final String consultationMethod;
  final int consultationDuration;
  final DateTime? scheduledDate;
  final String clientToken;

  const ConsultationInfoBox({
    super.key,
    required this.consultationType,
    required this.consultationMethod,
    required this.consultationDuration,
    required this.scheduledDate,
    required this.clientToken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Text(
              "Consultation Details",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Info rows
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow("Type:", consultationType),
                _buildInfoRow("Method:", consultationMethod),
                _buildInfoRow("Duration:", "${consultationDuration} minutes"),
                _buildInfoRow("Scheduled:",
                    scheduledDate != null
                        ? DateFormat('MMM dd, yyyy - HH:mm').format(scheduledDate!)
                        : "Not scheduled"
                ),
                if (clientToken.isNotEmpty)
                  _buildInfoRow("Client Token:", clientToken),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsultationPersonBox extends StatelessWidget {
  final String title;
  final String name;
  final String email;
  final String phone;
  final String photo;

  const ConsultationPersonBox({
    super.key,
    required this.title,
    required this.name,
    required this.email,
    required this.phone,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Photo
          if (photo.isNotEmpty)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(photo),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Info rows
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow("Name:", name),
                if (email.isNotEmpty) _buildInfoRow("Email:", email),
                if (phone.isNotEmpty) _buildInfoRow("Phone:", phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsultationApplicationsSection extends StatelessWidget {
  final List<Consultation> applications;

  const ConsultationApplicationsSection({
    super.key,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConsultationSection(
          title: "Related Applications",
          content: "Applications associated with this client:",
        ),
        const SizedBox(height: 16),
        ...applications.take(5).map((app) => _buildApplicationItem(app)),
      ],
    );
  }

  Widget _buildApplicationItem(Consultation application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            application.type,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Stage: ${application.status}",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (application.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              "Created: ${DateFormat('MMM dd, yyyy').format(application.createdAt!)}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}