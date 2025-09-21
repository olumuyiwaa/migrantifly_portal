// dart
import 'class_users.dart';

class Transaction {
  final String id;
  final ClientRef client;
  final ApplicationRef? application;
  final double amount;
  final String currency;
  final String type; // e.g., deposit
  final String status; // e.g., completed
  final String paymentMethod; // e.g., credit_card
  final String transactionId; // e.g., pi_123456...
  final String gatewayReference; // e.g., stripe_ref_123
  final String invoiceNumber; // e.g., INV-2025-001
  final String invoiceUrl;
  final int? v; // __v (optional)
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.client,
    required this.application,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.paymentMethod,
    required this.transactionId,
    required this.gatewayReference,
    required this.invoiceNumber,
    required this.invoiceUrl,
    required this.createdAt,
    required this.updatedAt,
    this.v,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final num amountNum = (json['amount'] ?? 0);
    return Transaction(
      id: json['_id'] ?? '',
      client: ClientRef.fromJson(json['clientId'] ?? const {}),
      application: json['applicationId'] != null
          ? ApplicationRef.fromJson(json['applicationId'])
          : null,
      amount: amountNum.toDouble(),
      currency: json['currency'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
      gatewayReference: json['gatewayReference'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      invoiceUrl: json['invoiceUrl'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime(1970),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime(1970),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clientId': client.toJson(),
      'applicationId': application?.toJson(),
      'amount': amount,
      'currency': currency,
      'type': type,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'gatewayReference': gatewayReference,
      'invoiceNumber': invoiceNumber,
      'invoiceUrl': invoiceUrl,
      '__v': v,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convenience getters for UI
  String get clientFullName => client.profile?.fullName ?? (client.email.isNotEmpty ? client.email : 'Client');
  String get visaType => application?.visaType ?? '';
}

class ApplicationRef {
  final String id;
  final String visaType;

  ApplicationRef({
    required this.id,
    required this.visaType,
  });

  factory ApplicationRef.fromJson(Map<String, dynamic> json) {
    return ApplicationRef(
      id: json['_id'] ?? '',
      visaType: json['visaType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'visaType': visaType,
    };
  }
}

class ClientRef {
  final String id;
  final String email;
  final User? profile;

  ClientRef({
    required this.id,
    required this.email,
    required this.profile,
  });

  factory ClientRef.fromJson(Map<String, dynamic> json) {
    return ClientRef(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'] != null ? User.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'profile': profile?.toJson(),
    };
  }
}