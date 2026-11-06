import 'dart:convert';

import 'package:http/http.dart' as http;

/// Geographische Koordinaten.
class GeoCoordinates {
  const GeoCoordinates({required this.lat, required this.lon});

  final double lat;
  final double lon;
}

/// Geokodierung von Adressen über OSM Nominatim.
class GeocodingService {
  const GeocodingService();

  /// Adresse → Koordinaten; `null` bei Fehler oder unbekannter Adresse.
  Future<GeoCoordinates?> geocode({
    required String street,
    required String zip,
    required String city,
  }) async {
    final String query = Uri.encodeComponent('$street, $zip $city');
    final Uri uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&limit=1&q=$query',
    );
    try {
      final http.Response response = await http.get(
        uri,
        headers: const {'User-Agent': 'galabau-app/1.0 (local-first)'},
      );
      if (response.statusCode != 200) return null;
      final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
      if (list.isEmpty) return null;
      final Map<String, dynamic> first = list.first as Map<String, dynamic>;
      final double? lat = double.tryParse(first['lat'] as String? ?? '');
      final double? lon = double.tryParse(first['lon'] as String? ?? '');
      if (lat == null || lon == null) return null;
      return GeoCoordinates(lat: lat, lon: lon);
    } catch (_) {
      return null;
    }
  }
}
