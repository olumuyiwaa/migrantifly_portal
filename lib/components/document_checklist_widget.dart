import 'package:flutter/material.dart';

import '../api/api_get.dart';
import '../models/class_visa_document_requirement.dart';
import '../responsive.dart';

class DocumentChecklistWidget extends StatelessWidget {
  final String visaType;
  const DocumentChecklistWidget({super.key, required this.visaType});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentRequirement>>(
      future: fetchChecklist(visaType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data ?? [];

        return Wrap(
          spacing: 2,
          runSpacing: 2,
          children: docs.map((doc) {
            return SizedBox(
              width: Responsive.isMobile(context)?MediaQuery.of(context).size.width-20:200,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        doc.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: doc.formats
                            .map((f) => Text(f, style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500)))
                            .toList(),
                      )
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
