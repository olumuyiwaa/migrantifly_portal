import 'package:flutter/material.dart';
import '../../api/api_get.dart';
import '../../models/class_documents.dart'; // import your Document class
import '../../constants.dart';

class DocumentsWidget extends StatefulWidget {
  const DocumentsWidget({super.key});

  @override
  State<DocumentsWidget> createState() => _DocumentsWidgetState();
}

class _DocumentsWidgetState extends State<DocumentsWidget> {
  int _selectedIndex = -1;
  bool _isLoadingDocuments = true;
  bool _showDetails = false;

  List<Document> documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    if (mounted) setState(() => _isLoadingDocuments = true);
    try {
      // Load cached data first
      documents = await loadCachedDocuments();
      if (mounted && documents.isNotEmpty) {
        setState(() {});
        setState(() => _isLoadingDocuments = false);
      }

      // Fetch fresh data
      final freshDocuments = await fetchDocuments();
      await cacheDocuments(freshDocuments);

      if (mounted) {
        setState(() {
          documents = freshDocuments;
          _isLoadingDocuments = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching documents: $e');
      if (mounted) {
        setState(() => _isLoadingDocuments = false);
      }
    }
  }

  void _onDocumentTap(int index) {
    setState(() {
      _selectedIndex = index;
      _showDetails = true;
    });
  }

  void _closeDetails() {
    setState(() {
      _showDetails = false;
      _selectedIndex = -1;
    });
  }

  Future<void> _downloadDocument(Document doc) async {
    // TODO: Implement download functionality
    // You can use url_launcher or file download packages
    debugPrint("Downloading document: ${doc.name}");

    // Example implementation:
    // final url = doc.downloadUrl; // Assuming you have a download URL
    // if (await canLaunch(url)) {
    //   await launch(url);
    // }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Downloading ${doc.name}..."),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Stack(
        children: [
          _buildDocumentGrid(),
          if (_showDetails) _buildDocumentDetailOverlay(),
        ],
      ),
    );
  }

  Widget _buildDocumentGrid() {
    if (_isLoadingDocuments) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (documents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No documents uploaded",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return _buildDocumentCard(documents[index], index);
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  Widget _buildDocumentCard(Document doc, int index) {
    return GestureDetector(
      onTap: () => _onDocumentTap(index),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: _selectedIndex == index
                ? Border.all(color: primaryColor, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document icon and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getDocumentColor(doc).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getDocumentIcon(doc),
                      color: _getDocumentColor(doc),
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(doc.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      doc.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Document type
              Text(
                doc.type.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),

              // Document name
              Expanded(
                child: Text(
                  doc.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // File size
              Row(
                children: [
                  Icon(Icons.storage, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    "${(doc.fileSize / (1024 * 1024)).toStringAsFixed(1)} MB",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    doc.clientId.fullName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onDocumentTap(index),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("View", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _downloadDocument(doc),
                    icon: const Icon(Icons.download, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentDetailOverlay() {
    if (_selectedIndex == -1 || _selectedIndex >= documents.length) {
      return const SizedBox.shrink();
    }

    final doc = documents[_selectedIndex];

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDocumentIcon(doc),
                      color: _getDocumentColor(doc),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: _closeDetails,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Detail content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata section
                      _buildDetailRow(
                        Icons.description_outlined,
                        "Document Type",
                        doc.type.toUpperCase(),
                      ),
                      _buildDetailRow(
                        Icons.file_present,
                        "Original Name",
                        doc.originalName,
                      ),
                      _buildDetailRow(
                        Icons.storage,
                        "File Size",
                        "${(doc.fileSize / (1024 * 1024)).toStringAsFixed(2)} MB",
                      ),
                      _buildDetailRow(
                        Icons.code,
                        "MIME Type",
                        doc.mimeType,
                      ),

                      // Status section
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.verified_outlined, color: Colors.green),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(doc.status),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              doc.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      _buildDetailRow(
                        Icons.person_outline,
                        "Uploaded By",
                        doc.clientId.fullName,
                      ),

                      // Review notes
                      if (doc.reviewNotes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.notes_outlined,
                          "Review Notes",
                          doc.reviewNotes,
                        ),
                      ],

                      // Reviewed by
                      if (doc.reviewedBy != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          Icons.person_outline,
                          "Reviewed By",
                          doc.reviewedBy!.fullName,
                        ),
                      ],

                      const Spacer(),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // TODO: open document in browser/viewer
                                debugPrint("Opening document: ${doc.name}");
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text("Open Document"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _downloadDocument(doc),
                              icon: const Icon(Icons.download),
                              label: const Text("Download"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                const SizedBox(height: 2),
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
}