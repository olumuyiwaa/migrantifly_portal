import 'package:flutter/material.dart';

import '../api/api_get.dart';
import '../models/class_documents.dart';
import '../models/class_visa_document_requirement.dart';
import '../responsive.dart';
import 'document_details.dart';

class UploadedDocument extends StatefulWidget {
  final String applicationId;
  const UploadedDocument({super.key, required this.applicationId});

  @override
  State<UploadedDocument> createState() => _UploadedDocumentState();
}

class _UploadedDocumentState extends State<UploadedDocument> {
  List<Document> docs =[];
  bool isLoading =false;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  Future<void> loadDocument() async {
    if (mounted) setState(() => isLoading = true);
    try {
      docs = await fetchUploadedDocuments(widget.applicationId);
      if (mounted && docs.isNotEmpty) {
        setState(() => isLoading = false);
      }
      final freshDocs = await fetchUploadedDocuments(widget.applicationId);
      // await WalletCache.saveWallet(freshWalletAccount);
      if (mounted) {
        setState(() {
          docs = freshDocs;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading wallet: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    void _openApplicationDetailsDrawer(BuildContext context, Document doc) {
      final width = MediaQuery.of(context).size.width;
      final drawerWidth = width < 500 ? width * 0.9 : 360.0;

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Document Details',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, anim1, anim2) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: drawerWidth,
                height: double.infinity,
                child:  DocumentDetails(doc: doc,onClose: () {Navigator.pop(context);},isClient: true,),
              ),
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnim = Tween<Offset>(
            begin: const Offset(1, 0), // slide in from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return SlideTransition(position: offsetAnim, child: child);
        },
      );
    }
    return (docs.isEmpty&&isLoading)?
      Center(child: CircularProgressIndicator(color: Colors.blue,)):
      docs.isEmpty? Text("Yet to upload any documents") : Wrap(
      spacing: 2,
      runSpacing: 2,
      children: docs.map((doc) {
        return SizedBox(
          width: Responsive.isMobile(context)?MediaQuery.of(context).size.width-20:200,
          child: InkWell(onTap: (){_openApplicationDetailsDrawer(context,doc);},child:  Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  Icon(_getDocumentIcon(doc),size: 42,color: _getDocumentColor(doc),),
                  const SizedBox(height: 4),

                  Text(
                    doc.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doc.status,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doc.reviewNotes,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  )
                ],
              ),
            ),
          )),
        );
      }).toList(),
    );
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