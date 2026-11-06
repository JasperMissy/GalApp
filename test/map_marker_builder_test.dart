import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/colleague.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/services/map/map_marker_builder.dart';

Client _client(String id, String name, {double? lat, double? lon}) => Client(
      id: id,
      name: name,
      street: 'Straße 1',
      zip: '12345',
      city: 'Ort',
      phone: '',
      email: '',
      createdAt: DateTime(2026),
      lat: lat,
      lon: lon,
    );

Colleague _colleague(String id, String name, {double? lat, double? lon}) =>
    Colleague(
      id: id,
      name: name,
      street: 'Straße 1',
      zip: '12345',
      city: 'Ort',
      phone: '',
      email: '',
      qualifications: const [],
      notes: '',
      createdAt: DateTime(2026),
      lat: lat,
      lon: lon,
    );

Order _order(String id, String clientId, String title,
        {OrderStatus status = OrderStatus.offen}) =>
    Order(
      id: id,
      clientId: clientId,
      title: title,
      description: '',
      createdAt: DateTime(2026),
      dueDateStart: null,
      dueDateEnd: null,
      status: status,
      recurring: false,
      notes: '',
    );

void main() {
  test('kunden: nur Kunden mit Koordinaten', () {
    final List<Client> clients = <Client>[
      _client('a', 'Mit Koordinaten', lat: 1.0, lon: 2.0),
      _client('b', 'Ohne Koordinaten'),
    ];

    final List<MapMarkerData> markers = buildMapMarkers(
      clients: clients,
      orders: const <Order>[],
      colleagues: const <Colleague>[],
      filter: MapFilter.kunden,
    );

    expect(markers, hasLength(1));
    expect(markers.single.title, 'Mit Koordinaten');
    expect(markers.single.kind, MapMarkerKind.kunde);
  });

  test('offeneAuftraege: nur offene Aufträge mit Kundenposition', () {
    final List<Client> clients = <Client>[
      _client('a', 'Kunde A', lat: 1.0, lon: 2.0),
      _client('b', 'Kunde B', lat: 3.0, lon: 4.0),
    ];
    final List<Order> orders = <Order>[
      _order('o1', 'a', 'Offen'),
      _order('o2', 'b', 'Erledigt', status: OrderStatus.erledigt),
      _order('o3', 'unbekannt', 'Unbekannter Kunde'),
    ];

    final List<MapMarkerData> markers = buildMapMarkers(
      clients: clients,
      orders: orders,
      colleagues: const <Colleague>[],
      filter: MapFilter.offeneAuftraege,
    );

    expect(markers, hasLength(1));
    expect(markers.single.title, 'Offen');
    expect(markers.single.kind, MapMarkerKind.auftrag);
    expect(markers.single.lat, 1.0);
    expect(markers.single.lon, 2.0);
  });

  test('kollegen: nur Kollegen mit Koordinaten', () {
    final List<Colleague> colleagues = <Colleague>[
      _colleague('m1', 'Mit Koordinaten', lat: 5.0, lon: 6.0),
      _colleague('m2', 'Ohne Koordinaten'),
    ];

    final List<MapMarkerData> markers = buildMapMarkers(
      clients: const <Client>[],
      orders: const <Order>[],
      colleagues: colleagues,
      filter: MapFilter.kollegen,
    );

    expect(markers, hasLength(1));
    expect(markers.single.title, 'Mit Koordinaten');
    expect(markers.single.kind, MapMarkerKind.kollege);
    expect(markers.single.lat, 5.0);
    expect(markers.single.lon, 6.0);
  });
}
