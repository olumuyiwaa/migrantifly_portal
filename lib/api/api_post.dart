import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/class_users.dart';
import 'api_helper.dart';

Future<void> postNote(String applicationId, String type, String description, DateTime? dueDate) async {
  final headers = await getHeaders();
  final url = Uri.parse("$baseUrl/applications/$applicationId/$type");
  final body = jsonEncode({
    "description": description,
    "dueDate": (dueDate ?? DateTime.now()).toIso8601String(),
  });

  final res = await http.post(url,
      headers: headers, body: body);

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception("Failed to add $type note: ${res.body}");
  }
}

Future<void> postApplication(BuildContext context, String consultationId, String visaType) async {
  final headers = await getHeaders();
  final url = Uri.parse("$baseUrl/applications");
  final body = jsonEncode({
    "visaType": visaType,
    "consultationId": consultationId,
  });

  final res = await http.post(url, headers: headers, body: body);

  if (res.statusCode != 200 && res.statusCode != 201) {
    final decoded = json.decode(res.body);
    final errorMessage = decoded['message'] ?? 'Unknown error occurred';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed to create $visaType Application: $errorMessage",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
    }
    throw Exception("Failed to create $visaType Application: $errorMessage");
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "$visaType Application Created Successfully",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    }
  }
}

Future<void> submitToInz(String applicationId, String inzReference) async {
  final headers = await getHeaders();
  final url = Uri.parse("$baseUrl/applications/$applicationId/submit-to-inz");
  final body = jsonEncode({"inzReference": inzReference});

  final res = await http.patch(url,
      headers: headers, body: body);

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception("Failed to submit to INZ: ${res.body}");
  }
}

Future<void> sendAssignAdviserRequest(
    BuildContext context,
    String applicationId,
    String adviserId,
    ) async {
  var headers = await getHeaders();
  final body = jsonEncode({"adviserId": adviserId});

  try {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/applications/$applicationId/assign-adviser'),
      headers: headers,
      body: body,
    );

    debugPrint("📤 Sent payload: $body");
    debugPrint("📥 Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final message = json.decode(response.body)["message"] ??
          "Adviser assigned successfully!";
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      final decoded = json.decode(response.body);
      String errorMessage = "Failed to assign adviser";

      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String) {
          errorMessage = decoded['message'];
        } else if (decoded['message'] is List) {
          errorMessage = (decoded['message'] as List).join('\n');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ));
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.toString(),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
    }
  }
}

Future<void> assignAdviserConsultation(
    BuildContext context,
    String consultationId,
    String adviserId,
    ) async {
  var headers = await getHeaders();
  final body = jsonEncode({"adviserId": adviserId});

  try {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/consultations/$consultationId/assign-adviser'),
      headers: headers,
      body: body,
    );

    debugPrint("📤 Sent payload: $body");
    debugPrint("📥 Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final message = json.decode(response.body)["message"] ??
          "Adviser assigned successfully!";
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      final decoded = json.decode(response.body);
      String errorMessage = "Failed to assign adviser";

      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String) {
          errorMessage = decoded['message'];
        } else if (decoded['message'] is List) {
          errorMessage = (decoded['message'] as List).join('\n');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ));
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.toString(),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
    }
  }
}

Future<void> createAdviserAccount({
  required BuildContext context,
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String phone,
  required String nationality,
}) async {
  try {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse("$baseUrl/admin/create-adviser"),
      headers: headers,
      body: json.encode({
        "email": email,
        "password": password,
        "profile": {
          "firstName": firstName,
          "lastName": lastName,
          "phone": phone,
          "nationality": nationality,
        },
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adviser account created successfully')),
      );
      Navigator.pop(context); // Close modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to create adviser')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

Future<void> uploadDocument({
  required BuildContext context,
  required String applicationId,
  required String documentType,
  required PlatformFile? selectedFile,
  String? expiryDate,
}) async {
  if (selectedFile == null) {
    throw Exception("No file selected for upload");
  }

  final fileName = selectedFile.name;
  print("📄 Uploading: $fileName");

  try {
    final headers = await getHeaders();
    final uri = Uri.parse("$baseUrl/documents/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['applicationId'] = applicationId
      ..fields['documentType'] = documentType;

    if (expiryDate != null && expiryDate.isNotEmpty) {
      request.fields['expiryDate'] = expiryDate;
    }

    // Attach file
    final fileBytes = selectedFile.bytes!;
    request.files.add(http.MultipartFile.fromBytes(
      'document',
      fileBytes,
      filename: fileName,
    ));

    request.headers.addAll(headers);

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("✅ Upload successful: $responseBody");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document uploaded successfully!")),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      throw Exception("Upload failed (${response.statusCode}): $responseBody");
    }
  } catch (e) {
    print("⚠️ Error uploading document: $e");
    rethrow;
  }
}

Future<Map<String, dynamic>> reviewDocument({
  required BuildContext context,
  required String documentId,
  required String status,
  required String reviewNotes,
}) async {
  try {
    final headers = await getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/documents/$documentId/review'),
      headers: headers,
      body: jsonEncode({
        'status': status,
        'reviewNotes': reviewNotes,
      }),
    );

    final isOk = response.statusCode == 200 || response.statusCode == 201;
    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (isOk) {
      return {
        'success': true,
        'data': decoded,
        'message': (decoded is Map && decoded['message'] is String)
            ? decoded['message']
            : 'Document reviewed successfully',
      };
    } else {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': (decoded is Map && decoded['message'] is String)
            ? decoded['message']
            : 'Failed to review document: ${response.statusCode}',
        'error': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error occurred while reviewing document',
      'error': e.toString(),
    };
  }
}
