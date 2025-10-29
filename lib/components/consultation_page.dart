import 'package:Migrantifly/responsive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_delete.dart';
import '../api/api_get.dart';
import '../api/api_post.dart';
import '../api/api_update.dart';
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
  List<User> users = [];
  bool _isLoading = true;
  String userID = "";

  void _showEditConsultationFormModal(
      BuildContext context, Consultation consultation) {
    final TextEditingController notesController = TextEditingController();
    final TextEditingController visaPathwaysController = TextEditingController();
    bool proceedWithApplication = false;

    Future<void> _saveChanges() async {
      try {
        await completeConsultation(
          context: context,
          consultationId: consultation.id,
          notes: notesController.text.trim(),
          visaPathways: visaPathwaysController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          proceedWithApplication: proceedWithApplication,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to handle checkbox state updates
        bool localProceedWithApplication = proceedWithApplication;

        // Parse existing visa pathways
        List<String> selectedVisaTypes = visaPathwaysController.text
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList();

        final availableVisaTypes = ['work', 'partner', 'student', 'residence', 'visitor', 'business'];

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * (Responsive.isMobile(context)? 0.9:0.6),
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              children: [
                // Modern header with blue gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade600,
                        Colors.blue.shade400,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: AppBar(
                    title: const Text(
                      'Update Consultation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,color: Colors.white
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                      SizedBox(width: 8,)
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Notes field with improved styling
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: notesController,
                              decoration: InputDecoration(
                                hintText: 'Enter consultation notes...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blue.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              maxLines: 8,
                              minLines: 5,
                            ),

                            const SizedBox(height: 24),

                            // Visa pathways with chips
                            Text(
                              'Visa Pathways',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select all applicable visa types',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).cardColor,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: availableVisaTypes.map((visaType) {
                                  final isSelected = selectedVisaTypes.contains(visaType);
                                  return FilterChip(
                                    label: Text(
                                      visaType.toUpperCase(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedVisaTypes.add(visaType);
                                        } else {
                                          selectedVisaTypes.remove(visaType);
                                        }
                                        // Update the controller
                                        visaPathwaysController.text = selectedVisaTypes.join(', ');
                                      });
                                    },
                                    selectedColor: Colors.blue.shade600,
                                    checkmarkColor: Colors.white,
                                    backgroundColor: Colors.grey.shade100,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.blue.shade600
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Checkbox with card background
                            InkWell(
                              onTap: () {
                                setState(() {
                                  localProceedWithApplication = !localProceedWithApplication;
                                  proceedWithApplication = localProceedWithApplication;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: localProceedWithApplication
                                        ? Colors.blue.shade600
                                        : Colors.grey.shade300,
                                    width: localProceedWithApplication ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: localProceedWithApplication
                                      ? Colors.blue.shade50
                                      : Theme.of(context).cardColor,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: Colors.blue,
                                      value: localProceedWithApplication,
                                      onChanged: (value) {
                                        setState(() {
                                          localProceedWithApplication = value ?? false;
                                          proceedWithApplication = localProceedWithApplication;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Proceed with Application',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Mark this consultation as ready to proceed',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Bottom action bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _saveChanges();
                            widget.onChange();
                            _fetchConsultationDetails();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchConsultationDetails() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final consultation = widget.consultation;

      // 1. Load cached users (don’t block on errors)
      users = await loadCachedUsers().catchError((e) {
        debugPrint('Error loading cached users: $e');
        return <User>[]; // fallback
      });

      // 2. Fetch fresh users and consultations in parallel
      final results = await Future.wait([
        fetchUsers().catchError((e) {
          debugPrint('Error fetching fresh users: $e');
          return <User>[];
        }),
        fetchConsultations().catchError((e) {
          debugPrint('Error fetching consultations: $e');
          return <Consultation>[];
        }),
      ]);

      final freshUsers = results[0] as List<User>;
      final fetchedApplications = results[1] as List<Consultation>;

      // Update cached users if fresh results available
      if (freshUsers.isNotEmpty) {
        users = freshUsers;
        await cacheUsers(freshUsers);
      }

      // 3. Filter applications related to this client
      final clientId = consultation.client?.id;
      final clientRelated = clientId == null
          ? <Consultation>[]
          : fetchedApplications.where((app) => app.client?.id == clientId).toList();

      // 4. Update state in a single batch
      if (!mounted) return;
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

        // Client details (safe null checks)
        clientName = consultation.client?.fullName ?? '';
        clientEmail = consultation.client?.email ?? '';
        clientPhone = consultation.client?.phoneNumber ?? '';
        clientPhoto = consultation.client?.image ?? '';

        // Adviser details (safe null checks)
        adviserName = consultation.adviser?.fullName ?? '';
        adviserEmail = consultation.adviser?.email ?? '';
        adviserPhone = consultation.adviser?.phoneNumber ?? '';
        adviserPhoto = consultation.adviser?.image ?? '';

        allApplications = clientRelated;
        relatedApplications = clientRelated;

        _isLoading = false;
      });
    } catch (error, st) {
      debugPrint("Error fetching consultation details: $error");
      debugPrintStack(stackTrace: st);
      if (mounted) setState(() => _isLoading = false);
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

  String userRole = '';
  Future<void> getUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          userID = prefs.getString('id') ?? '';
          userRole = prefs.getString('role') ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error getting user info: $e');
    }
  }

  Future<void> _retryLoading() async {
    await _fetchConsultationDetails();
    if (mounted) {
      widget.onChange();
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "Consultation Not Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "There was an error loading the consultation details.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryLoading,
              child: const Text("Try Again"),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Consultation header
          ConsultationHeader(
            consultationType: consultationType,
            consultationStatus: consultationStatus,
          consultationID:widget.consultation.id,userRole:userRole,
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
Future<void> _assignAdviser(BuildContext context, String consultationId) async {
  // Show loading dialog with adviser selection
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _AssignAdviserDialog(consultationId: consultationId),
  );
}
// Separate StatefulWidget for Assign Adviser Dialog
class _AssignAdviserDialog extends StatefulWidget {
  final String consultationId;

  const _AssignAdviserDialog({required this.consultationId});

  @override
  State<_AssignAdviserDialog> createState() => _AssignAdviserDialogState();
}

class _AssignAdviserDialogState extends State<_AssignAdviserDialog> {
  User? selectedAdviser;
  List<User> advisers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      // Step 1: Load from cache
      final cachedUsers = await loadCachedUsers();
      advisers = cachedUsers.where((user) => user.role == 'adviser').toList();

      if (mounted && advisers.isNotEmpty) {
        setState(() {}); // update UI with cached data first
      }

      // Step 2: Fetch fresh users from API
      final freshUsers = await fetchUsers();
      await cacheUsers(freshUsers);

      // Step 3: Filter advisers from fresh list
      final freshAdvisers = freshUsers.where((user) => user.role == 'adviser').toList();

      if (mounted) {
        setState(() {
          advisers = freshAdvisers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Assign Adviser'),
      content: _isLoading
          ? const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      )
          : DropdownButtonFormField<User>(
        decoration: const InputDecoration(
          labelText: "Select Adviser",
          border: OutlineInputBorder(),
        ),
        value: selectedAdviser,
        items: advisers
            .map(
              (adviser) => DropdownMenuItem<User>(
            value: adviser,
            child: Text(adviser.fullName.capitalizeWords()),
          ),
        )
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedAdviser = value;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedAdviser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Please select an adviser",
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final adviserId = selectedAdviser!.id;
            await assignAdviserConsultation(context, widget.consultationId, adviserId);
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

class ConsultationHeader extends StatelessWidget {
  final String consultationType;
  final String consultationID;
  final String userRole;
  final String consultationStatus;
  final VoidCallback onEdit;

  const ConsultationHeader({
    super.key,
    required this.consultationType,
    required this.consultationID,
    required this.userRole,
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
                      Flexible(
                        child: Text(
                          consultationType.isNotEmpty ? consultationType : 'General Consultation',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Georgia',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(consultationStatus),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          consultationStatus.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (userRole.toLowerCase() == "admin")
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Assign Adviser',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _assignAdviser(context, consultationID);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                if (!consultationStatus.toLowerCase().contains("complete"))
                  SizedBox(width: 12,),
                // Action button
                if (!consultationStatus.toLowerCase().contains("complete"))
                  IconButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_note_sharp, color: Colors.white),
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

// Keep the rest of the widget classes unchanged as they are well-implemented
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
            flex: 5,
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
            flex: 2,
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
            child: const Text(
              "Consultation Details",
              style: TextStyle(
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

          // Photo with error handling
          if (photo.isNotEmpty)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Image.network(
                photo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey[400],
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
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
        const ConsultationSection(
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