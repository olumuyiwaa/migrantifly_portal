import 'dart:convert';
import 'dart:io';

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