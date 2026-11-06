/// Kunde (Datenklasse, 1:1 zum Schema `clients`).
class Client {
  const Client({
    required this.id,
    required this.name,
    required this.street,
    required this.zip,
    required this.city,
    required this.phone,
    required this.email,
    required this.createdAt,
    this.lat,
    this.lon,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json['id'] as String,
        name: json['name'] as String,
        street: json['street'] as String? ?? '',
        zip: json['zip'] as String? ?? '',
        city: json['city'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        lat: (json['lat'] as num?)?.toDouble(),
        lon: (json['lon'] as num?)?.toDouble(),
      );

  final String id;
  final String name;
  final String street;
  final String zip;
  final String city;
  final String phone;
  final String email;
  final DateTime createdAt;
  final double? lat;
  final double? lon;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'street': street,
        'zip': zip,
        'city': city,
        'phone': phone,
        'email': email,
        'created_at': createdAt.toIso8601String(),
        'lat': lat,
        'lon': lon,
      };
}