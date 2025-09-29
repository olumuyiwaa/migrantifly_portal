import 'package:flutter/material.dart';
import '../../api/api_get.dart';
import '../../components/document_details.dart';
import '../../models/class_documents.dart';
import '../../constants.dart';

class DocumentsWidget extends StatefulWidget {
  final String? clientId;
  const DocumentsWidget({super.key, this.clientId});

  @override
  State<DocumentsWidget> createState() => _DocumentsWidgetState();
}

class _DocumentsWidgetState extends State<DocumentsWidget> {
  int _selectedIndex = -1;
  bool _isLoadingDocuments = true;

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
     final documentsList = await loadCachedDocuments();
     (widget.clientId != null)?
      documents = documentsList.where((document) =>
      document.clientId!.id == widget.clientId).toList():documents=documentsList;
      if (mounted && documents.isNotEmpty) {
        setState(() {});
        setState(() => _isLoadingDocuments = false);
      }

      // Fetch fresh data
      final freshDocuments = await fetchDocuments();
      await cacheDocuments(freshDocuments);

      if (mounted) {
        setState(() {
          (widget.clientId != null)?
          documents = freshDocuments.where((document) =>
          document.clientId!.id == widget.clientId).toList():documents=freshDocuments;
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
      _selectedIndex = _selectedIndex == index ? -1 : index;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  Future<void> _downloadDocument(Document doc) async {
    // TODO: Implement download functionality
    debugPrint("Downloading document: ${doc.name}");

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
      child: Row(
        children: [
          // Documents grid - takes up available space or full width when no selection
          Expanded(
            flex: _selectedIndex == -1 ? 1 : 2,
            child: _buildDocumentGrid(),
          ),

          // Side panel - only shows when document is selected
          if (_selectedIndex != -1 && _selectedIndex < documents.length)
            Container(
              width: 400,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: _buildDocumentDetailPanel(),
            ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with selection info
          if (_selectedIndex != -1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Document selected - view details in the side panel",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearSelection,
                    child: Text("Clear Selection"),
                  ),
                ],
              ),
            ),

          // Grid view
          Expanded(
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
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Adjust grid based on whether side panel is showing
    final availableWidth = _selectedIndex == -1 ? width : width - 400;

    if (availableWidth > 1200) return 4;
    if (availableWidth > 900) return 3;
    if (availableWidth > 600) return 2;
    return 1;
  }

  Widget _buildDocumentCard(Document doc, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onDocumentTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: isSelected ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: isSelected
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

                // File size and client
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
                    const Spacer(),
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        doc.clientId?.fullName ?? "N/A",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
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
                          backgroundColor: isSelected ? primaryColor : null,
                        ),
                        child: Text(
                          isSelected ? "Selected" : "Select",
                          style: const TextStyle(fontSize: 12),
                        ),
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
      ),
    );
  }

  Widget _buildDocumentDetailPanel() {
    final doc = documents[_selectedIndex];

    return DocumentDetails(doc: doc,onClose:_clearSelection,isClient: false,);
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