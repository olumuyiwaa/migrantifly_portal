import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
