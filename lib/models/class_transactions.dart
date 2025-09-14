// models/class_transaction.dart
class Transaction {
  final String id;
  final String transactionId;
  final String userId;
  final TicketInfo? ticketId;
  final double amount;
  final int ticketCount;
  final String? ticketType;
  final String? ticketTypeName;
  final double? pricePerTicket;
  final String? status;
  final String paymentStatus;
  final String? stripeSessionId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.transactionId,
    required this.userId,
    this.ticketId,
    required this.amount,
    required this.ticketCount,
    this.ticketType,
    this.ticketTypeName,
    this.pricePerTicket,
    this.status,
    required this.paymentStatus,
    this.stripeSessionId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? '',
      transactionId: json['transactionId'] ?? '',
      userId: json['userId'] ?? '',
      ticketId: json['ticketId'] != null ? TicketInfo.fromJson(json['ticketId']) : null,
      amount: (json['amount'] ?? 0).toDouble(),
      ticketCount: json['ticketCount'] ?? 0,
      ticketType: json['ticketType'],
      ticketTypeName: json['ticketTypeName'],
      pricePerTicket: json['pricePerTicket']?.toDouble(),
      status: json['status'],
      paymentStatus: json['paymentStatus'] ?? 'unknown',
      stripeSessionId: json['stripeSessionId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'transactionId': transactionId,
      'userId': userId,
      'ticketId': ticketId?.toJson(),
      'amount': amount,
      'ticketCount': ticketCount,
      'ticketType': ticketType,
      'ticketTypeName': ticketTypeName,
      'pricePerTicket': pricePerTicket,
      'status': status,
      'paymentStatus': paymentStatus,
      'stripeSessionId': stripeSessionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TicketInfo {
  final String id;
  final String image;
  final String title;
  final String location;
  final String date;
  final String category;

  TicketInfo({
    required this.id,
    required this.image,
    required this.title,
    required this.location,
    required this.date,
    required this.category,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) {
    return TicketInfo(
      id: json['_id'] ?? '',
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'title': title,
      'location': location,
      'date': date,
      'category': category,
    };
  }
}