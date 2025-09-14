class Buyer {
  final String fullName;
  final int ticketCount;
  final double amount;
  final DateTime purchaseDate;

  Buyer({
    required this.fullName,
    required this.ticketCount,
    required this.amount,
    required this.purchaseDate,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      fullName: json['full_name'],
      ticketCount: json['ticketCount'],
      amount: (json['amount'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate']),
    );
  }
}

class TicketsSales {
  final int totalTicketsSold;
  final List<Buyer> buyers;

  TicketsSales({
    required this.totalTicketsSold,
    required this.buyers,
  });

  factory TicketsSales.fromJson(Map<String, dynamic> json) {
    return TicketsSales(
      totalTicketsSold: json['totalTicketsSold'],
      buyers: (json['buyers'] as List)
          .map((buyer) => Buyer.fromJson(buyer))
          .toList(),
    );
  }
}
