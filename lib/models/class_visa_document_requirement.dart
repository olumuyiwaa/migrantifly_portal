class DocumentRequirement {
  final String type;
  final String name;
  final String description;
  final bool required;
  final List<String> formats;

  DocumentRequirement({
    required this.type,
    required this.name,
    required this.description,
    required this.required,
    required this.formats,
  });

  factory DocumentRequirement.fromJson(Map<String, dynamic> json) {
    return DocumentRequirement(
      type: json['type'],
      name: json['name'],
      description: json['description'],
      required: json['required'],
      formats: List<String>.from(json['formats']),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'required': required,
    'formats': formats,
  };
}
