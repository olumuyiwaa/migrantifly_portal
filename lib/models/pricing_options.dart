class PricingOption {
  String name;
  String price;
  String available;
  String description;

  PricingOption({
    required this.name,
    required this.price,
    required this.available,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'available': available,
    'description': description,
  };
}