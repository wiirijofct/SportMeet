class Field {
  final String fieldId;
  final String name;
  final String location;
  final String openTime;
  final String closeTime;
  final String pricing;
  final bool isPublic;
  final String email;
  final String phone;
  final List<String> images;

  Field({
    required this.fieldId,
    required this.name,
    required this.location,
    required this.openTime,
    required this.closeTime,
    required this.pricing,
    required this.isPublic,
    required this.email,
    required this.phone,
    required this.images,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      fieldId: json['fieldId'],
      name: json['name'],
      location: json['location'],
      openTime: json['schedule']['open'],
      closeTime: json['schedule']['close'],
      pricing: json['pricing'],
      isPublic: json['isPublic'],
      email: json['contact']['email'],
      phone: json['contact']['phone'],
      images: List<String>.from(json['images']),
    );
  }
}
