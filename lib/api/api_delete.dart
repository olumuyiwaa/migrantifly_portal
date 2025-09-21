import 'dart:convert';

// import 'package:afrohub/screens/main_screens/event_management/ticket_shop.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import '../../screens/active_session.dart';
import 'api_helper.dart';

Future<void> removeUser({
  required BuildContext context,
  required String userID,
}) async {
  var headers = await getHeaders();

  // Create multipart request
  var request = http.Request(
      'DELETE', Uri.parse('$baseUrl/users/delete-account/?userId=$userID'))
    ..headers.addAll(headers);
  final response = await request.send();

  // Handle the response
  if (response.statusCode == 200||response.statusCode == 200) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'User removed successfully!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop();
    }
  } else {
    final responseData = await http.Response.fromStream(response);
    final String errorMessage = json.decode(responseData.body)['message'] ??
        'Failed to remove User';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
      Navigator.of(context).pop();
    }
    throw Exception(errorMessage);
  }
}

Future<void> removeApplication({
  required BuildContext context,
  required String applicationID,
}) async {
  var headers = await getHeaders();

  // Create multipart request
  var request =
      http.Request('DELETE', Uri.parse('$baseUrl/events/$applicationID/delete'))
        ..headers.addAll(headers);
  final response = await request.send();

  // Handle the response
  if (response.statusCode == 200) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Event deleted successfully!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop();
    }
  } else {
    final responseData = await http.Response.fromStream(response);
    final String errorMessage =
        json.decode(responseData.body)['message'] ?? 'Failed to delete event';

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
}

Future<void> removeCountry({
  required BuildContext context,
  required String countryID,
}) async {
  var headers = await getHeaders();

  // Create multipart request
  var request =
      http.Request('DELETE', Uri.parse('$baseUrl/country/countries/$countryID'))
        ..headers.addAll(headers);
  final response = await request.send();

  // Handle the response
  if (response.statusCode == 200) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Country deleted successfully!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop();
    }
  } else {
    const String errorMessage = 'Failed to delete country';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
      Navigator.of(context).pop();
    }
    throw Exception(errorMessage);
  }
}

Future<void> removeBusiness({
  required BuildContext context,
  required String businessID,
}) async {
  var headers = await getHeaders();

  // Create multipart request
  var request =
      http.Request('DELETE', Uri.parse('$baseUrl/business/$businessID'))
        ..headers.addAll(headers);
  final response = await request.send();

  // Handle the response
  if (response.statusCode == 200||response.statusCode == 201) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Business deleted successfully!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
    }
    Navigator.of(context).pop();
  } else {
    const String errorMessage = 'Failed to delete business';
    Navigator.of(context).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
    }
    throw Exception(errorMessage);
  }
}
