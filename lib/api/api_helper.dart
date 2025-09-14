import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';

const String baseUrl = 'https://migrantifly-backend.onrender.com/api';

Future<Map<String, String>> getHeaders() async {
  await ensureValidToken();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    throw Exception('No authentication token found');
  }

  return {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}
