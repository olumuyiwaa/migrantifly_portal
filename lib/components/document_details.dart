import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../models/class_documents.dart';

class DocumentDetails extends StatefulWidget {
  final Document doc;
  final VoidCallback onClose;
  final bool isClient;
  const DocumentDetails({super.key, required this.doc, required this.onClose, required this.isClient});

  @override
  State<DocumentDetails> createState() => _DocumentDetailsState();
}

class _DocumentDetailsState extends State<DocumentDetails> {

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }
  String userRole = '';
  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
    });
  }

  Future<void> _openDocumentUrl(BuildContext context, Document doc) async {
    final String? url = doc.fileUrl;

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No URL available for ${doc.name}')),
      );
      return;
    }

    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        // Prefer opening in an external app (browser or native viewer)
        final ok = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );

        // Fallback to in-app browser view if external app fails
        if (!ok) {
          final ok2 = await launchUrl(
            uri,
            mode: LaunchMode.inAppBrowserView,
          );
          if (!ok2) throw Exception('Launching URL failed');
        }
      } else {
        throw Exception('Cannot handle URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getDocumentIcon(widget.doc),
                      color: _getDocumentColor(widget.doc),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Document Preview",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.doc.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    CloseButton(onPressed: widget.onClose,style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),

          // Detail content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.doc.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.doc.status.toLowerCase() == 'approved'
                              ? Icons.check_circle
                              : widget.doc.status.toLowerCase() == 'rejected'
                              ? Icons.cancel
                              : Icons.schedule,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.doc.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Document details
                  _buildDetailSection("Document Information", [
                    _buildDetailRow(Icons.description_outlined, "Type", widget.doc.type.toUpperCase()),
                    _buildDetailRow(Icons.file_present, "Original Name", widget.doc.originalName),
                    _buildDetailRow(Icons.storage, "File Size", "${(widget.doc.fileSize / (1024 * 1024)).toStringAsFixed(2)} MB"),
                    _buildDetailRow(Icons.code, "MIME Type", widget.doc.mimeType),
                  ]),
                  if (!widget.isClient)
                  const SizedBox(height: 24),
                  if (!widget.isClient)
                  // Client information
                  _buildDetailSection("Client Information", [
                    _buildDetailRow(Icons.person_outline, "Uploaded By",widget.doc.clientId?.fullName ?? "N/A"),
                  ]),

                  // Review information
                  if (widget.doc.reviewNotes.isNotEmpty || widget.doc.reviewedBy != null) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection("Review Information", [
                      if (widget.doc.reviewedBy != null)
                        _buildDetailRow(Icons.person_outline, "Reviewed By", widget.doc.reviewedBy!.fullName),
                      if (widget.doc.reviewNotes.isNotEmpty)
                        _buildDetailRow(Icons.notes_outlined, "Review Notes", widget.doc.reviewNotes),
                    ]),
                  ],

                  const SizedBox(height: 32),

                  // Action buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (userRole.toLowerCase() != "client")
                        ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => reviewDoc(context, widget.doc.id),
                        icon: const Icon(Icons.rate_review_rounded,color: Colors.white,),
                        label: const Text("Review Document",style: TextStyle(color: Colors.white),),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _openDocumentUrl(context, widget.doc),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Open Document"),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _downloadDocument(widget.doc,context),
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _downloadDocument(Document doc, BuildContext context) async {
  // TODO: Implement download functionality
  debugPrint("Downloading document: ${doc.name}");

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Downloading ${doc.name}..."),
      backgroundColor: primaryColor,
    ),
  );
}

Widget _buildDetailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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
void reviewDoc(BuildContext context, String documentId) {
  String note = '';
  String selectedStatus = "pending";
  List<String> documentStatus = ['pending', 'approved', 'rejected', 'under_review'];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Review Document', style: TextStyle(fontSize: 32)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: "Document Status",
              border: OutlineInputBorder(),
            ),
            items: documentStatus
                .map(
                  (status) => DropdownMenuItem(
                value: status,
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                ),
              ),
            )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
              });
            },
          ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => note = value,
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
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: const Text('Submit',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDetailSection(String title, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: children,
        ),
      ),
    ],
  );
}
IconData _getDocumentIcon(Document doc) {
  switch (doc.mimeType.toLowerCase()) {
    case 'application/pdf':
      return Icons.picture_as_pdf;
    case 'application/msword':
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      return Icons.description;
    case 'application/vnd.ms-excel':
    case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      return Icons.table_chart;
    case 'image/jpeg':
    case 'image/png':
    case 'image/gif':
      return Icons.image;
    default:
      return Icons.insert_drive_file;
  }
}

Color _getDocumentColor(Document doc) {
  switch (doc.mimeType.toLowerCase()) {
    case 'application/pdf':
      return Colors.red;
    case 'application/msword':
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      return Colors.blue;
    case 'application/vnd.ms-excel':
    case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      return Colors.green;
    case 'image/jpeg':
    case 'image/png':
    case 'image/gif':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    case 'pending':
    default:
      return Colors.orange;
  }
}