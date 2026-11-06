import '../../models/client.dart';
import '../../models/colleague.dart';
import '../../models/order.dart';
import '../../models/order_status.dart';

/// Filter der Kartenansicht.
enum MapFilter { kunden, offeneAuftraege, kollegen }

/// Art eines Karten-Markers.
enum MapMarkerKind { kunde, auftrag, kollege }

/// Positions-Marker für die Karte (ohne UI-Abhängigkeit).
class MapMarkerData {
  const MapMarkerData({
    required this.lat,
    required this.lon,
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final double lat;
  final double lon;
  final String title;
  final String subtitle;
  final MapMarkerKind kind;
}

/// Baut die Karten-Marker für einen Filter.
///
/// Offene Aufträge werden über die Adresse ihres Kunden positioniert.
/// Kollegen folgen, sobald die Kollegen-Datenbank existiert.
List<MapMarkerData> buildMapMarkers({
  required List<Client> clients,
  required List<Order> orders,
  required List<Colleague> colleagues,
  required MapFilter filter,
}) {
  final Map<String, Client> byId = <String, Client>{
    for (final Client c in clients) c.id: c,
  };
  final List<MapMarkerData> result = <MapMarkerData>[];

  switch (filter) {
    case MapFilter.kunden:
      for (final Client c in clients) {
        final double? lat = c.lat;
        final double? lon = c.lon;
        if (lat == null || lon == null) continue;
        result.add(MapMarkerData(
          lat: lat,
          lon: lon,
          title: c.name,
          subtitle: _address(c.street, c.zip, c.city),
          kind: MapMarkerKind.kunde,
        ));
      }
    case MapFilter.offeneAuftraege:
      for (final Order o in orders) {
        if (o.status != OrderStatus.offen) continue;
        final Client? client = byId[o.clientId];
        if (client == null) continue;
        final double? lat = client.lat;
        final double? lon = client.lon;
        if (lat == null || lon == null) continue;
        result.add(MapMarkerData(
          lat: lat,
          lon: lon,
          title: o.title,
          subtitle: client.name,
          kind: MapMarkerKind.auftrag,
        ));
      }
    case MapFilter.kollegen:
      for (final Colleague c in colleagues) {
        final double? lat = c.lat;
        final double? lon = c.lon;
        if (lat == null || lon == null) continue;
        result.add(MapMarkerData(
          lat: lat,
          lon: lon,
          title: c.name,
          subtitle: _address(c.street, c.zip, c.city),
          kind: MapMarkerKind.kollege,
        ));
      }
  }

  return result;
}

String _address(String street, String zip, String city) => '$street, $zip $city';
