class Business {
  final String id;
  final String businessTitle;
  final String businessDescription;
  final String businessLocation;
  final String businessAddress;
  final String businessCategory;
  final String twitter;
  final String facebook;
  final String instagram;
  final String webAddress;
  final String linkedIn;
  final String whatsapp;
  final List<String> mediaFiles;

  Business({
    required this.id,
    required this.businessTitle,
    required this.businessDescription,
    required this.businessLocation,
    required this.businessAddress,
    required this.businessCategory,
    required this.twitter,
    required this.facebook,
    required this.instagram,
    required this.webAddress,
    required this.linkedIn,
    required this.whatsapp,
    required this.mediaFiles,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['_id']?.toString() ?? '',
      businessTitle: json['businessTitle'] ?? '',
      businessDescription: json['businessDescription'] ?? '',
      businessLocation: json['businessLocation'] ?? '',
      businessAddress: json['businessAddress'] ?? '',
      businessCategory: json['businessCategory'] ?? '',
      twitter: json['twitter'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      webAddress: json['webAddress'] ?? '',
      linkedIn: json['linkedIn'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      mediaFiles: (json['mediaFiles'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>() // Ensure it's a map
          .map((e) => e['fileUrl']?.toString() ?? '') // Extract fileUrl
          .where((url) => url.isNotEmpty) // Filter out empty URLs
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'businessTitle': businessTitle,
      'businessDescription': businessDescription,
      'businessLocation': businessLocation,
      'businessAddress': businessAddress,
      'businessCategory': businessCategory,
      'twitter': twitter,
      'facebook': facebook,
      'instagram': instagram,
      'webAddress': webAddress,
      'linkedIn': linkedIn,
      'whatsapp': whatsapp,
      'mediaFiles': mediaFiles,
    };
  }

  factory Business.empty() {
    return Business(
      id: '',
      businessTitle: '',
      businessDescription: '',
      businessLocation: '',
      businessAddress: '',
      businessCategory: '',
      twitter: '',
      facebook: '',
      instagram: '',
      webAddress: '',
      linkedIn: '',
      whatsapp: '',
      mediaFiles: [],
    );
  }

}
