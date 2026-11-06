import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/colleague.dart' as model;
import '../database/app_database.dart';
import '../database/providers.dart';
import '../geocoding_service.dart';

/// CRUD-Zugriff auf Kollegen (`colleagues`).
class ColleagueRepository {
  const ColleagueRepository(this.db,
      {this.geocoder = const GeocodingService()});

  final AppDatabase db;
  final GeocodingService geocoder;

  /// Alle Kollegen, alphabetisch nach Name sortiert.
  Stream<List<model.Colleague>> watchAll() {
    final query = db.select(db.colleagues)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  /// Ein einzelner Kollege (oder null).
  Future<model.Colleague?> getById(String id) async {
    final row = await (db.select(db.colleagues)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<void> insert(model.Colleague colleague) async {
    GeoCoordinates? coords;
    if (colleague.street.trim().isNotEmpty) {
      coords = await geocoder.geocode(
        street: colleague.street,
        zip: colleague.zip,
        city: colleague.city,
      );
    }
    await db.into(db.colleagues).insert(
          ColleaguesCompanion.insert(
            id: colleague.id,
            name: colleague.name,
            street: Value(colleague.street),
            zip: Value(colleague.zip),
            city: Value(colleague.city),
            phone: Value(colleague.phone),
            email: Value(colleague.email),
            qualifications: Value(colleague.qualifications),
            notes: Value(colleague.notes),
            lat: Value(coords?.lat),
            lon: Value(coords?.lon),
            createdAt: colleague.createdAt,
          ),
        );
  }

  model.Colleague _toModel(Colleague row) => model.Colleague(
        id: row.id,
        name: row.name,
        street: row.street,
        zip: row.zip,
        city: row.city,
        phone: row.phone,
        email: row.email,
        qualifications: row.qualifications,
        notes: row.notes,
        createdAt: row.createdAt,
        lat: row.lat,
        lon: row.lon,
      );
}

final colleagueRepositoryProvider = Provider<ColleagueRepository>((ref) {
  return ColleagueRepository(ref.watch(databaseProvider));
});

final colleaguesProvider = FutureProvider<List<model.Colleague>>((ref) {
  return ref.watch(colleagueRepositoryProvider).watchAll().first;
});
