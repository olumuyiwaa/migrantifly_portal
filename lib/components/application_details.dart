// dart
import 'dart:io';

import 'package:Migrantifly/components/uploaded_documents.dart';
import 'package:Migrantifly/models/class_documents.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_delete.dart';
import '../api/api_get.dart';
import '../api/api_post.dart';
import '../api/api_update.dart';
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
    getUserInfo();
  }

  @override
  void dispose() {
    staffInputController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    if (mounted) setState(() => _isLoadingDocuments = true);
    try {
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

  void _showQuickActions(BuildContext context, String applicationId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDialogAction(
                icon: Icons.flag,
                title: 'Application Stage',
                subtitle: 'Update the application stage',
                onTap: () {
                  Navigator.pop(context);
                  _updateStage(context,applicationId);
                },
              ),
              _buildDialogAction(
                icon: Icons.check_circle,
                title: 'Update Decision',
                subtitle: 'Record decision for this application',
                onTap: () {
                  Navigator.pop(context);
                  _submitDecision(context,applicationId);
                },
              ),
              _buildDialogAction(
                icon: Icons.note_add,
                title: 'Add Note',
                subtitle: 'Add a note to this application',
                onTap: () {
                  Navigator.pop(context);
                  _addNote(context, applicationId);
                },
              ),
              _buildDialogAction(
                icon: Icons.upload_file,
                title: 'Upload Document',
                subtitle: 'Upload a new document',
                onTap: () {
                  Navigator.pop(context);
                  _uploadDocument(context);
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _assignAdviser(BuildContext context, String applicationId) async {
    // Show loading dialog with adviser selection
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AssignAdviserDialog(applicationId: applicationId),
    );
  }

  Widget _buildDialogAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.grey[700]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
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
    PlatformFile? selectedFile;
    double uploadProgress = 0.0;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickFile() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
              );

              if (result != null && result.files.isNotEmpty) {
                setState(() {
                  selectedFile = result.files.single;
                });
              }
            }

            Future<void> simulateUpload() async {
              setState(() => isUploading = true);
              for (var i = 1; i <= 10; i++) {
                await Future.delayed(const Duration(milliseconds: 200));
                setState(() => uploadProgress = i / 10);
              }
              setState(() => isUploading = false);

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Document uploaded successfully!")),
              );
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.all(24),
              title: const Text('Upload Document', style: TextStyle(fontWeight: FontWeight.w600)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Upload area
                    GestureDetector(
                      onTap: pickFile,
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 48, color: Colors.grey[500]),
                            const SizedBox(height: 8),
                            const Text(
                              "Drag and Drop file here or Choose file",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Supported formats: PDF, DOC, DOCX, JPG, PNG",
                              style: TextStyle(color: Colors.grey[500], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dropdown for document type
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Document Type",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedType,
                      items: documentTypes
                          .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type.replaceAll("_", " ").capitalizeWords())))
                          .toList(),
                      onChanged: (value) => setState(() => selectedType = value),
                    ),

                    const SizedBox(height: 20),

                    // File preview
                    if (selectedFile != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file, color: Colors.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(selectedFile!.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    "${(selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => setState(() {
                                selectedFile = null;
                                uploadProgress = 0;
                              }),
                            ),
                          ],
                        ),
                      ),

                    if (isUploading) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: uploadProgress,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.blueAccent,
                        backgroundColor: Colors.grey[300],
                      ),
                    ],
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: (selectedType != null && selectedFile != null && !isUploading)
                      ? simulateUpload
                      : null,
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _addNote(BuildContext context, String applicationId) {
    String note = '';
    DateTime? dueDate;
    String selectedType = "ppi";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.all(24),
            title: Row(
              children: const [
                Icon(Icons.note_add_outlined, color: Colors.blueAccent, size: 28),
                SizedBox(width: 8),
                Text(
                  'Add Note',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown for type
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: "Select Note Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "ppi", child: Text("PPI")),
                      DropdownMenuItem(value: "rfi", child: Text("RFI")),
                      DropdownMenuItem(value: "inz", child: Text("Submit to INZ")),
                    ],
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),

                  const SizedBox(height: 16),

                  // Note text field
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter your note here...',
                      labelText: 'Note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) => note = value.trim(),
                  ),

                  const SizedBox(height: 16),

                  // Date picker (conditional)
                  if (selectedType == "ppi" || selectedType == "rfi")
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => dueDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          dueDate != null
                              ? "${dueDate!.toLocal().toString().split(' ')[0]}"
                              : "Select due date",
                          style: TextStyle(
                            color: dueDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  // ✅ Validation
                  if (note.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a note.')),
                    );
                    return;
                  }
                  if ((selectedType == "ppi" || selectedType == "rfi") && dueDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a due date.')),
                    );
                    return;
                  }

                  Navigator.of(context).pop();

                  // ✅ Execute API logic
                  if (selectedType == "ppi" || selectedType == "rfi") {
                    await postNote(applicationId, selectedType, note, dueDate);
                  } else if (selectedType == "inz") {
                    await submitToInz(applicationId, note);
                  }

                  // ✅ Confirmation feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedType == "inz"
                            ? 'Submitted to INZ successfully'
                            : 'Note added successfully',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
  void _updateStage(BuildContext context, String applicationId) {
    final List<String> stages = [
      'consultation',
      'deposit_paid',
      'documents_completed',
      'additional_docs_required',
      'submitted_to_inz',
      'inz_processing',
      'rfi_received',
      'ppi_received',
      'decision',
    ];

    String? selectedStage;
    String notes = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Update Application Stage', style: TextStyle(fontSize: 24)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStage,
                  decoration: const InputDecoration(
                    labelText: "Select Stage",
                    border: OutlineInputBorder(),
                  ),
                  items: stages
                      .map((stage) => DropdownMenuItem(
                      value: stage,
                      child: Text(stage.replaceAll('_', ' ').toUpperCase())))
                      .toList(),
                  onChanged: (value) => setState(() => selectedStage = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add any relevant notes...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => notes = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedStage != null
                  ? () async {
                Navigator.of(context).pop();

                await postStageUpdate(applicationId, selectedStage!, notes);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stage updated successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitDecision(BuildContext context, String applicationId) {
    final List<String> outcomes = ['approved', 'declined', 'pending'];

    String? selectedOutcome;
    String notes = '';
    File? decisionLetter;
    double uploadProgress = 0.0;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text(
            'Submit Decision',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedOutcome,
                  decoration: const InputDecoration(
                    labelText: "Decision Outcome",
                    border: OutlineInputBorder(),
                  ),
                  items: outcomes
                      .map((outcome) => DropdownMenuItem(
                      value: outcome, child: Text(outcome.capitalizeWords())))
                      .toList(),
                  onChanged: (value) => setState(() => selectedOutcome = value),
                ),
                const SizedBox(height: 16),

                // File upload section
                GestureDetector(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx'],
                    );
                    if (result != null) {
                      setState(() {
                        decisionLetter = File(result.files.single.path!);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: decisionLetter == null
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.upload_file, size: 48, color: Colors.blue),
                        const SizedBox(height: 8),
                        const Text(
                          'Drag and drop file here or click to choose file',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Supported: PDF, DOC, DOCX — Max size 25MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file,
                                color: Colors.green, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                decisionLetter!.path.split('/').last,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() => decisionLetter = null),
                            ),
                          ],
                        ),
                        if (isUploading)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(
                              value: uploadProgress,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => notes = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: selectedOutcome != null && decisionLetter != null && !isUploading
                  ? () async {
                setState(() {
                  isUploading = true;
                  uploadProgress = 0.3; // Fake progress start
                });

                await Future.delayed(const Duration(seconds: 1)); // simulate delay

                try {
                  await postDecision(
                    applicationId,
                    selectedOutcome!,
                    notes,
                    decisionLetter!,
                        (progress) => setState(() => uploadProgress = progress),
                  );

                  setState(() => uploadProgress = 1.0);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Decision submitted successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                } finally {
                  setState(() => isUploading = false);
                }
              }
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }


  String userRole = '';
  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
    });
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
                    Row(
                      spacing: defaultPadding,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildSection('Application Details', [
                            _buildDetailItem(Icons.description, 'Visa Type',
                                _nonEmpty(app.visaType)),
                            _buildDetailItem(
                                Icons.flag, 'Stage', _nonEmpty(app.stage)),
                            _buildDetailItem(Icons.trending_up, 'Progress',
                                "${app.progress}%"),
                            _buildDetailItem(Icons.confirmation_number,
                                'Destination Country', _nonEmpty(app.destinationCountry)),
                          ]),
                        ),
                        Expanded(
                          child: _buildSection('Adviser', [
                            _buildDetailItem(Icons.person_outline, 'Name',
                                _nonEmpty(app.adviser.fullName)),
                            _buildDetailItem(Icons.email_outlined, 'Email',
                                _nonEmpty(app.adviser.email)),
                            _buildDetailItem(Icons.phone_outlined, 'Phone',
                                _nonEmpty(app.adviser.phoneNumber)),
                            _buildDetailItem(Icons.location_on, 'Location',
                                _nonEmpty(app.adviser.countryLocated)),
                          ]),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      spacing: defaultPadding,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildSection('Key Dates', [
                            _buildDetailItem(Icons.calendar_today, 'Created',
                                _fmt(app.createdAt)),
                            _buildDetailItem(Icons.update, 'Last Updated',
                                _fmt(app.updatedAt)),
                            _buildDetailItem(Icons.timeline, 'Latest Timeline Stage',
                                _nonEmpty(app.latestTimelineEntry?.stage)),
                            _buildDetailItem(Icons.event_note,
                                'Latest Timeline Date', _fmt(app.latestTimelineEntry?.date)),
                            if ((app.latestTimelineEntry?.notes ?? '').isNotEmpty)
                              _buildDetailItem(Icons.notes, 'Latest Notes',
                                  app.latestTimelineEntry!.notes!),
                          ]),
                        ),
                        Expanded(
                          child: _buildSection('Required Documents', [
                            DocumentChecklistWidget(
                              visaType: app.visaType,
                            )
                          ]),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSection('Client', [
                            _buildDetailItem(Icons.person, 'Name',
                                _nonEmpty(app.client.fullName)),
                            _buildDetailItem(Icons.email, 'Email',
                                _nonEmpty(app.client.email)),
                            _buildDetailItem(Icons.phone, 'Phone',
                                _nonEmpty(app.client.phoneNumber)),
                            _buildDetailItem(Icons.location_on, 'Location',
                                _nonEmpty(app.client.countryLocated)),
                            _buildDetailItem(Icons.home, 'Address',
                                _nonEmpty(app.client.fullAddress)),
                          ]),
                        ),
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
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 30),
                        const Text(
                          "Documents",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        UploadedDocument(
                          applicationId: app.id,
                        )
                      ],
                    )
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
    if (img.isNotEmpty) {
      return Image.network(img,
          height: 372, width: double.infinity, fit: BoxFit.cover);
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              spacing: 12,
              children: [
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
                    _assignAdviser(context, widget.application.id);
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
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.update,
                    color: Colors.blue,
                  ),
                  label: const Text(
                    'Update',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    _showQuickActions(context, widget.application.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
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

// Separate StatefulWidget for Assign Adviser Dialog
class _AssignAdviserDialog extends StatefulWidget {
  final String applicationId;

  const _AssignAdviserDialog({required this.applicationId});

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
            await sendAssignAdviserRequest(context, widget.applicationId, adviserId);
          },
          child: const Text('Assign'),
        ),
      ],
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