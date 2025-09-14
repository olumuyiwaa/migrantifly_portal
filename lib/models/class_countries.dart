class Country {
  final String id;
  final String image;
  final String title;
  final String president;
  final String capital;
  final String currency;
  final String population;
  final String demonym;
  final double? latitude;
  final double? longitude;
  final String description;
  final String language;
  final String timeZone;
  final String link;
  final String? artCraft;
  final String? culturalDance;
  final String createdById;

  Country({
    required this.id,
    required this.image,
    required this.title,
    required this.president,
    required this.capital,
    required this.currency,
    required this.population,
    required this.demonym,
    this.latitude,
    this.longitude,
    required this.description,
    required this.language,
    required this.timeZone,
    required this.link,
    this.artCraft,
    this.culturalDance,
    required this.createdById,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['_id'] ?? '',
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      president: json['president'] ?? '',
      capital: json['capital'] ?? '',
      currency: json['currency'] ?? '',
      population: json['population'] ?? '',
      demonym: json['demonym'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] ?? '',
      language: json['language'] ?? '',
      timeZone: json['time_zone'] ?? '',
      link: json['link'] ?? '',
      artCraft: json['arts_and_crafts']?.toString(),
      culturalDance: json['cultural_dance']?.toString(),
      createdById: json['created_by_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'title': title,
      'president': president,
      'capital': capital,
      'currency': currency,
      'population': population,
      'demonym': demonym,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'language': language,
      'time_zone': timeZone,
      'link': link,
      'arts_and_crafts': artCraft,
      'cultural_dance': culturalDance,
      'created_by_id': createdById,
    };
  }

  factory Country.empty() {
  return Country(
    id: '',
    image: '',
    title: '',
    president: '',
    capital: '',
    currency: '',
    population: '',
    demonym: '',
    latitude: null,
    longitude: null,
    description: '',
    language: '',
    timeZone: '',
    link: '',
    artCraft: null,
    culturalDance: null,
    createdById: '',
  );
}
}
