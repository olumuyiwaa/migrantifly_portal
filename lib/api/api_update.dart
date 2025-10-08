import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_helper.dart';

Future<void> completeConsultation({
  required BuildContext context,
  required String consultationId,
  required String notes,
  required List<String> visaPathways,
  required bool proceedWithApplication,
}) async {
  var headers = await getHeaders();

  final request = http.Request(
    'PATCH',
    Uri.parse('$baseUrl/consultation/$consultationId/complete'),
  )
    ..headers.addAll(headers)
    ..body = json.encode({
      'notes': notes,
      'visaPathways': visaPathways,
      'proceedWithApplication': proceedWithApplication,
    });

  try {
    final response = await request.send();
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Consultation updated successfully!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ));
      }
      Navigator.pop(context);
    } else {
      String errorMessage = 'Failed to complete consultation';
      try {
        final responseData = await http.Response.fromStream(response);
        final decoded = json.decode(responseData.body);
        errorMessage = decoded['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = 'An unexpected error occurred';
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
      throw Exception(errorMessage);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to complete consultation: $e',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
    }
    rethrow;
  }
}


Future<void> roleUpdate({
  required BuildContext context,
  required String userID,
  required String role,
}) async {
  var headers = await getHeaders();

  // Create multipart request
  var request =
  http.Request('PUT', Uri.parse('$baseUrl/switch-role/users/$userID/role'))
    ..headers.addAll(headers)
    ..body = json.encode({
      'role': role,
    });

  try {
    // Send the request
    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'User Role Updated successfully!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } else {
      // Handle error response
      String errorMessage = 'User Role Update failed';
      try {
        final responseData = await http.Response.fromStream(response);
        errorMessage =
            json.decode(responseData.body)['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = 'An unexpected error occurred';
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
      throw Exception(errorMessage);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to update User Role: $e',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
    }
    rethrow;
  }
}
