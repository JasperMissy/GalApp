import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/client.dart' as model;
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/geocoding_service.dart';

/// Fake-Geocoder ohne Netzwerkzugriff.
class _FakeGeocoder extends GeocodingService {
  const _FakeGeocoder();

  @override
  Future<GeoCoordinates?> geocode({
    required String street,
    required String zip,
    required String city,
  }) async =>
      const GeoCoordinates(lat: 52.52, lon: 13.405);
}

void main() {
  late AppDatabase db;
  late ClientRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ClientRepository(db);
  });

  tearDown(() async => db.close());

  test('insert und watchAll (alphabetisch sortiert)', () async {
    await repo.insert(model.Client(
      id: 'k-2', name: 'Müller', street: '', zip: '', city: '', phone: '',
      email: '', createdAt: DateTime(2026),
    ));
    await repo.insert(model.Client(
      id: 'k-1', name: 'Berger', street: '', zip: '', city: '', phone: '',
      email: '', createdAt: DateTime(2026),
    ));

    final clients = await repo.watchAll().first;
    expect(clients.map((c) => c.name).toList(), ['Berger', 'Müller']);
  });

  test('insert geokodiert die Adresse und speichert lat/lon', () async {
    final geoRepo = ClientRepository(db, geocoder: const _FakeGeocoder());

    await geoRepo.insert(model.Client(
      id: 'k-3', name: 'Berlin', street: 'Unter den Linden 1', zip: '10117',
      city: 'Berlin', phone: '', email: '', createdAt: DateTime(2026),
    ));

    final client = await repo.getById('k-3');
    expect(client!.lat, closeTo(52.52, 0.0001));
    expect(client.lon, closeTo(13.405, 0.0001));
  });

  test('ohne Adresse bleiben lat/lon leer', () async {
    await repo.insert(model.Client(
      id: 'k-4', name: 'Ohne Adresse', street: '', zip: '', city: '',
      phone: '', email: '', createdAt: DateTime(2026),
    ));

    final client = await repo.getById('k-4');
    expect(client!.lat, isNull);
    expect(client.lon, isNull);
  });
}