import 'dart:convert';

// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:Migrantifly/models/class_documents.dart';
import 'package:Migrantifly/models/class_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/class_consultation.dart';
import '../models/class_applications.dart';
import '../models/class_transactions.dart';
import '../models/class_users.dart';
import '../models/dashboard_stats.dart';
import 'api_helper.dart';

Future<DashboardStats> getDashboardStats() async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/admin/dashboard'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final stats = DashboardStats.fromResponse(json.decode(response.body));
    await cacheDashboardStats(stats);
    return stats;
  } else {
    throw Exception('Failed to load Dashboard Stats: ${response.statusCode}');
  }
}

Future<void> cacheDashboardStats(DashboardStats stats) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = json.encode(stats.toJson());
  await prefs.setString("dashboard_stats", jsonString);
}

Future<DashboardStats?> loadCachedDashboardStats() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString("dashboard_stats");
  if (jsonString != null) {
    final Map<String, dynamic> decoded = json.decode(jsonString);
    return DashboardStats.fromJson(decoded);
  }
  return null;
}

Future<List<User>> fetchUsers() async {
  final headers = await getHeaders();
  int page = 1;
  const int limit = 20;
  final List<User> allUsers = [];

  while (true) {
    final uri = Uri.parse('$baseUrl/admin/users').replace(queryParameters: {
      'page': '$page',
      'limit': '$limit',
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> rows = data['data']['users'];

      final users = rows.map((e) => User.fromJson(e)).toList();
      allUsers.addAll(users);

      if (users.length < limit) {
        // We've reached the last page
        break;
      }

      page++; // ✅ increment page number
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  return allUsers;
}


//store users
Future<void> cacheUsers(List<User> users) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = users.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList('cached_users', encoded);
}

Future<List<User>> loadCachedUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('cached_users');
  if (data == null) return [];
  return data.map((item) => User.fromJson(jsonDecode(item))).toList();
}

Future<List<Document>> fetchDocuments() async {
  final headers = await getHeaders();
  int page = 1;
  const int limit = 20;
  final List<Document> allDocuments = [];

  while (true) {
    final uri = Uri.parse('$baseUrl/documents').replace(queryParameters: {
      'page': '$page',
      'limit': '$limit',
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> rows = data['data']['documents'];

      final documents = rows.map((e) => Document.fromJson(e)).toList();
      allDocuments.addAll(documents);

      if (documents.length < limit) {
        // We've reached the last page
        break;
      }

      page++; // ✅ increment page number
    } else {
      throw Exception('Failed to load documents: ${response.body}');
    }
  }

  return allDocuments;
}


//store Documents
Future<void> cacheDocuments(List<Document> documents) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = documents.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList('cached_documents', encoded);
}

Future<List<Document>> loadCachedDocuments() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('cached_documents');
  if (data == null) return [];
  return data.map((item) => Document.fromJson(jsonDecode(item))).toList();
}



//--------------------


Future<List<NotificationModel>> fetchNotifications() async {
  final headers = await getHeaders();
  int page = 1;
  const int limit = 20;
  final List<NotificationModel> allNotifications = [];

  while (true) {
    final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: {
      'page': '$page',
      'limit': '$limit',
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> rows = data['data']['notifications'];

      final notifications = rows.map((e) => NotificationModel.fromJson(e)).toList();
      allNotifications.addAll(notifications);

      if (notifications.length < limit) {
        // We've reached the last page
        break;
      }

      page++; // ✅ increment page number
    } else {
      throw Exception('Failed to load notifications: ${response.body}');
    }
  }

  return allNotifications;
}


//store Notifications
Future<void> cacheNotifications(List<NotificationModel> notifications) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = notifications.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList('cached_notifications', encoded);
}

Future<List<NotificationModel>> loadCachedNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('cached_notifications');
  if (data == null) return [];
  return data.map((item) => NotificationModel.fromJson(jsonDecode(item))).toList();
}

Future<List<Consultation>> fetchConsultations() async {
  final headers = await getHeaders();
  int page = 1;
  const int limit = 20;
  final List<Consultation> allConsultations = [];

  while (true) {
    final uri = Uri.parse('$baseUrl/consultation').replace(queryParameters: {
      'page': '$page',
      'limit': '$limit',
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> rows = data['data']['consultations'];

      final consultations = rows.map((e) => Consultation.fromJson(e)).toList();
      allConsultations.addAll(consultations);

      if (consultations.length < limit) {
        // We've reached the last page
        break;
      }

      page++; // ✅ increment page number
    } else {
      throw Exception('Failed to load consultations: ${response.body} $uri');
    }
  }

  return allConsultations;
}


//store users
Future<void> cacheConsultations(List<Consultation> consultations) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = consultations.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList('cached_consultations', encoded);
}

Future<List<Consultation>> loadCachedConsultations() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('cached_consultations');
  if (data == null) return [];
  return data.map((item) => Consultation.fromJson(jsonDecode(item))).toList();
}


//Application
Future<List<Application>> getFeaturedEvents() async {
  final headers = await getHeaders();
  int page = 1;
  const int limit = 20;
  final List<Application> allApplications = [];

  while (true) {
    final uri = Uri.parse('$baseUrl/applications').replace(queryParameters: {
      'page': '$page',
      'limit': '$limit',
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> rows = data['data']['applications'];

      final applications = rows.map((e) => Application.fromJson(e)).toList();
      allApplications.addAll(applications);

      if (applications.length < limit) {
        // We've reached the last page
        break;
      }

      page++; // ✅ increment page number
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  return allApplications;
}


//store application
Future<void> cacheEvents(List<Application> events) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = events.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList('cached_applications', encoded);
}

Future<List<Application>> loadCachedEvents() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('cached_applications');
  if (data == null) return [];
  return data.map((item) => Application.fromJson(jsonDecode(item))).toList();
}

Future<List<dynamic>> fetchMessages(String eventID) async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/chats/$eventID'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to load users');
  }
}


// -----transactions


class TransactionApi {
  static Future<List<Transaction>> fetchTransactions() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/payments/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)["data"];
        return jsonData.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }
}

// Cache management functions (similar to your business cache)
Future<List<Transaction>> loadCachedTransactions() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cached_transactions');
    if (cachedData != null) {
      List<dynamic> jsonList = json.decode(cachedData);
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    }
  } catch (e) {
    print('Error loading cached transactions: $e');
  }
  return [];
}

Future<void> cacheTransactions(List<Transaction> transactions) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString('cached_transactions', jsonString);
  } catch (e) {
    print('Error caching transactions: $e');
  }
}