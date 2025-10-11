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


Future<void> postStageUpdate(String id, String stage, String notes) async {
  try {
    final headers = await getHeaders();
    final url = Uri.parse('$baseUrl/applications/$id/stage');

    final response = await http.patch(
      url,
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'stage': stage,
        'notes': notes,
      }),
    );

    if (response.statusCode != 200) {
      // Try to parse error message from response
      String errorMessage = 'Failed to update stage';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        // If parsing fails, use default message
      }
      throw Exception(errorMessage);
    }
  } catch (e) {
    debugPrint('Error updating stage: $e');
    rethrow;
  }
}

Future<void> postDecision(
    String id,
    String outcome,
    String notes,
    File decisionLetter,
    Function(double) onProgress,
    ) async {
  try {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl/applications/$id/decision');

    // Create multipart request
    final request = http.MultipartRequest('PATCH', uri)
      ..headers.addAll(headers)
      ..fields['outcome'] = outcome
      ..fields['notes'] = notes;

    // Add file
    final fileStream = http.ByteStream(decisionLetter.openRead());
    final fileLength = await decisionLetter.length();

    final multipartFile = http.MultipartFile(
      'decisionLetter',
      fileStream,
      fileLength,
      filename: decisionLetter.path.split('/').last,
    );

    request.files.add(multipartFile);

    // Send request with progress tracking
    final streamedResponse = await request.send();

    // Track actual upload progress
    int bytesUploaded = 0;
    streamedResponse.stream.listen(
          (value) {
        bytesUploaded += value.length;
        final progress = bytesUploaded / fileLength;
        onProgress(progress.clamp(0.0, 1.0));
      },
      onError: (error) {
        throw Exception('Upload failed: $error');
      },
    );

    // Get response
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      // Try to parse error message
      String errorMessage = 'Failed to submit decision';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        // If parsing fails, use status code
        errorMessage = 'Failed to submit decision (${response.statusCode})';
      }
      throw Exception(errorMessage);
    }

    // Ensure progress reaches 100%
    onProgress(1.0);

  } catch (e) {
    debugPrint('Error submitting decision: $e');
    rethrow;
  }
}


