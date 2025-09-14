import 'dart:convert';

// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/class_business.dart';
import '../models/class_buyers.dart';
import '../models/class_countries.dart';
import '../models/class_event_locations.dart';
import '../models/class_applications.dart';
import '../models/class_tickets.dart';
import '../models/class_transactions.dart';
import '../models/class_users.dart';
import 'api_helper.dart';

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


//store events
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

Future<List<EventLocation>> getEventLocations() async {

  final headers = await getHeaders(); // Ensure you implement getHeaders
  final response = await http.get(
    Uri.parse('$baseUrl/events/featured'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);

    // Map event name and location
    final List<EventLocation> locations = jsonData.map((json) {
      return EventLocation(
        name: json['title'],
        date: json['date'],
        location: LatLng(json['latitude'], json['longitude']),
      );
    }).toList();

    return locations;
  } else {
    throw Exception('Failed to load event locations: ${response.statusCode}');
  }
}


Future<Application> getEventDetails(String eventID) async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/events/$eventID'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return Application.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load Event Details: ${response.statusCode}');
  }
}

Future<List<Country>> getCountries() async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/country/countries'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Country.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load Countries: ${response.statusCode}');
  }
}

Future<Country> getCountryDetails(String countryID) async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/country/countries/$countryID'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return Country.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load Country Details: ${response.statusCode}');
  }
}

Future<List<Ticket>> fetchTickets() async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/paypal/payment-history'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData
        .map((json) => Ticket.fromJson(json))
        .where((ticket) => ticket.status.toLowerCase() == "paid")
        .toList();
  } else {
    throw Exception('Failed to load tickets: ${response.reasonPhrase}');
  }
}

Future<TicketsSales> fetchTicketsSales(String eventID) async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/events/$eventID/buyers'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return TicketsSales.fromJson(jsonData);
  } else {
    final Map<String, dynamic> jsonData = json.decode(response.body);

    return jsonData['message'];
  }
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


Future<List<Business>> fetchBusinesses() async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/business'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    final List<dynamic> jsonData =
        json.decode(response.body); // Decode as a list
    return jsonData.map((e) => Business.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load Business');
  }
}

Future<Business> getBusinessDetails(String businessID) async {
  final headers = await getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/business/$businessID'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return Business.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load Business Details: ${response.statusCode}');
  }
}

//store countries
Future<void> cacheCountries(List<Country> countries) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = countries.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList('cached_countries', encoded);
}

Future<List<Country>> loadCachedCountries() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('cached_countries');
  if (data == null) return [];
  return data.map((item) => Country.fromJson(jsonDecode(item))).toList();
}

//store businesses
Future<void> cacheBusinesses(List<Business> businesses) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = businesses.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList('cached_businesses', encoded);
}

Future<List<Business>> loadCachedBusinesses() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('cached_businesses');
  if (data == null) return [];
  return data.map((item) => Business.fromJson(jsonDecode(item))).toList();
}


// -----transactions


class TransactionApi {
  static const String baseUrl = 'https://afrohub.onrender.com/api';

  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<Transaction>> fetchTransactions() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Cookie': 'token=$token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/stripe/admin/transactions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  static Future<Transaction?> fetchTransactionById(String transactionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Cookie': 'token=$token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/stripe/admin/transactions/$transactionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Transaction.fromJson(jsonData);
      } else {
        throw Exception('Failed to load transaction: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching transaction: $e');
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