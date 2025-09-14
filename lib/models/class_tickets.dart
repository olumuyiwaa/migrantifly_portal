class Ticket {
  final String id;
  final String transactionId;
  final String userId;
  final String ticketId; // ID inside the ticketId object
  final String image;
  final String title;
  final String? paypalUsername;
  final String location;
  final String date;
  final String price;
  final String category;
  final String time;
  final String address;
  final double latitude;
  final double longitude;
  final String organiser;
  final String description;
  final int unit;
  final String? paypalOrderId;
  final double amount;
  final int ticketCount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ticket({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.ticketId,
    required this.image,
    required this.title,
    this.paypalUsername,
    required this.location,
    required this.date,
    required this.price,
    required this.category,
    required this.time,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.organiser,
    required this.description,
    required this.unit,
    this.paypalOrderId,
    required this.amount,
    required this.ticketCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final ticketId = json['ticketId'] ?? {};

    return Ticket(
      id: json['_id'],
      transactionId: json['transactionId'],
      userId: json['userId'],
      ticketId: ticketId['_id'] ?? '',
      image: ticketId['image'] ?? '',
      title: ticketId['title'] ?? '',
      paypalUsername: ticketId['paypalUsername'],
      location: ticketId['location'] ?? '',
      date: ticketId['date'] ?? '',
      price: ticketId['price'] ?? '',
      category: ticketId['category'] ?? '',
      time: ticketId['time'] ?? '',
      address: ticketId['address'] ?? '',
      latitude: (ticketId['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (ticketId['longitude'] as num?)?.toDouble() ?? 0.0,
      organiser: ticketId['organiser'] ?? '',
      description: ticketId['description'] ?? '',
      unit: ticketId['unit'] ?? 0,
      paypalOrderId: json['paypalOrderId'],
      amount: (json['amount'] as num).toDouble(),
      ticketCount: json['ticketCount'],
      status: json['paymentStatus'] ?? "unpaid",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(ticketId['updatedAt']),
    );
  }
}
