import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/colleague.dart' as model;
import 'package:galabau_app/services/colleagues/colleague_repository.dart';
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
  late ColleagueRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ColleagueRepository(db);
  });

  tearDown(() async => db.close());

  test('insert und watchAll (alphabetisch, Qualifikationen, Notiz)', () async {
    await repo.insert(model.Colleague(
      id: 'm-2',
      name: 'Müller',
      street: '',
      zip: '',
      city: '',
      phone: '',
      email: '',
      qualifications: const ['SKT-A'],
      notes: '',
      createdAt: DateTime(2026),
    ));
    await repo.insert(model.Colleague(
      id: 'm-1',
      name: 'Berger',
      street: '',
      zip: '',
      city: '',
      phone: '',
      email: '',
      qualifications: const ['Anhängerführerschein', 'eigener Anhänger'],
      notes: 'Zuverlässig',
      createdAt: DateTime(2026),
    ));

    final colleagues = await repo.watchAll().first;
    expect(colleagues.map((c) => c.name).toList(), ['Berger', 'Müller']);
    expect(
      colleagues.first.qualifications,
      ['Anhängerführerschein', 'eigener Anhänger'],
    );
    expect(colleagues.first.notes, 'Zuverlässig');
  });

  test('insert geokodiert die Adresse und speichert lat/lon', () async {
    final geoRepo = ColleagueRepository(db, geocoder: const _FakeGeocoder());

    await geoRepo.insert(model.Colleague(
      id: 'm-3',
      name: 'Berlin',
      street: 'Unter den Linden 1',
      zip: '10117',
      city: 'Berlin',
      phone: '',
      email: '',
      qualifications: const [],
      notes: '',
      createdAt: DateTime(2026),
    ));

    final colleague = await repo.getById('m-3');
    expect(colleague!.lat, closeTo(52.52, 0.0001));
    expect(colleague.lon, closeTo(13.405, 0.0001));
  });

  test('ohne Adresse bleiben lat/lon leer', () async {
    await repo.insert(model.Colleague(
      id: 'm-4',
      name: 'Ohne Adresse',
      street: '',
      zip: '',
      city: '',
      phone: '',
      email: '',
      qualifications: const [],
      notes: '',
      createdAt: DateTime(2026),
    ));

    final colleague = await repo.getById('m-4');
    expect(colleague!.lat, isNull);
    expect(colleague.lon, isNull);
  });
}
