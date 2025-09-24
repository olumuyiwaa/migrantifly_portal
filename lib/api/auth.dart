// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/main/active_session.dart';
import '../screens/main/login.dart';
import 'api_helper.dart';

Future<void> signInAuth(
    BuildContext context,
    String email,
    String password, {
      bool rememberMe = false,
    }) async {
  final Map<String, dynamic> body = {
    'email': email,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse('https://migrantifly-backend.onrender.com/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final String token = (data['token'] ?? '').toString();
      final Map<String, dynamic>? user =
      data['user'] is Map<String, dynamic> ? data['user'] : null;
      final Map<String, dynamic> profile =
      user?['profile'] is Map<String, dynamic> ? user!['profile'] : {};

      // Save auth + user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('email', email);
      await prefs.setString('user_id', (user?['id'] ?? '').toString());
      await prefs.setString('role', (user?['role'] ?? '').toString());
      await prefs.setString('first_name', (profile['firstName'] ?? '').toString());
      await prefs.setString('last_name', (profile['lastName'] ?? '').toString());
      await prefs.setString('phone', (profile['phone'] ?? '').toString());
      // Handle "Remember me" credentials for reAuth
      if (rememberMe) {
        await prefs.setString('password', password);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('password');
        await prefs.setBool('remember_me', false);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login successful", textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ActiveSession()),
            (route) => false,
      );
    } else {
      // Safe error message extraction
      String errorMessage = "Login failed";
      try {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map && decoded['message'] is String) {
          errorMessage = decoded['message'] as String;
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e, st) {
    debugPrint('Login error: $e');
    debugPrint('Stack: $st');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Network Error, Kindly Check Your Internet Connection",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

}

Future<void> reAuth() async {
  final prefs = await SharedPreferences.getInstance();
  final userEmail = prefs.getString('email');
  final password = prefs.getString('password');
  final rememberMe = prefs.getBool('remember_me') ?? false;

  // If we have no saved credentials (or user opted out), nothing to do
  if (!rememberMe || userEmail == null || password == null) return;

  final Map<String, dynamic> body = {
    'email': userEmail,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String accessToken = (responseData['token'] ?? '').toString();

      await prefs.setString('token', accessToken);

      // Optionally refresh the user info too if returned
      if (responseData['user'] is Map<String, dynamic>) {
        final user = responseData['user'] as Map<String, dynamic>;
        final profile =
        user['profile'] is Map<String, dynamic> ? user['profile'] as Map<String, dynamic> : {};

        await prefs.setString('user_id', (user['id'] ?? '').toString());
        await prefs.setString('role', (user['role'] ?? '').toString());
        await prefs.setString('first_name', (profile['firstName'] ?? '').toString());
        await prefs.setString('last_name', (profile['lastName'] ?? '').toString());
        await prefs.setString('phone', (profile['phone'] ?? '').toString());
      }
    } else {
      // If re-login fails, leave the existing (possibly expired) token as-is;
      // caller can decide how to handle missing/expired token.
    }
  } catch (_) {
    // Silent failure for background re-auth
  }
}

bool isTokenExpired(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return true;

  try {
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload) as Map<String, dynamic>;
    final exp = payloadMap['exp'] as int?;
    if (exp == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return currentTime >= exp;
  } catch (_) {
    return true;
  }
}

Future<void> ensureValidToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || isTokenExpired(token)) {
    await reAuth();
  }
}

Future<void> signOut({
  required BuildContext context,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const LoginPage(),
      ),
          (Route<dynamic> route) => false,
    );
  }
}

Future<void> deleteAccount({
  required BuildContext context,
  required String? userID,
}) async {
  try {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/users/delete-account/?userId=$userID'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "User Account Successfully Deleted",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ));
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const LoginPage(),
          ),
              (Route<dynamic> route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "User Account Delete failed: ${response.reasonPhrase}",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Network Error, Kindly Check Your Internet Connection",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}