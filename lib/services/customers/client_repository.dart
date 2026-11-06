import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/client.dart' as model;
import '../database/app_database.dart';
import '../database/providers.dart';
import '../geocoding_service.dart';

/// CRUD-Zugriff auf die Kunden (`clients`).
class ClientRepository {
  const ClientRepository(this.db, {this.geocoder = const GeocodingService()});

  final AppDatabase db;
  final GeocodingService geocoder;

  /// Alle Kunden, alphabetisch nach Name sortiert.
  Stream<List<model.Client>> watchAll() {
    final query = db.select(db.clients)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  /// Ein einzelner Kunde (oder null).
  Future<model.Client?> getById(String id) async {
    final row = await (db.select(db.clients)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<void> insert(model.Client client) async {
    GeoCoordinates? coords;
    if (client.street.trim().isNotEmpty) {
      coords = await geocoder.geocode(
        street: client.street,
        zip: client.zip,
        city: client.city,
      );
    }
    await db.into(db.clients).insert(
          ClientsCompanion.insert(
            id: client.id,
            name: client.name,
            street: Value(client.street),
            zip: Value(client.zip),
            city: Value(client.city),
            phone: Value(client.phone),
            email: Value(client.email),
            lat: Value(coords?.lat),
            lon: Value(coords?.lon),
            createdAt: client.createdAt,
          ),
        );
  }

  model.Client _toModel(Client row) => model.Client(
        id: row.id,
        name: row.name,
        street: row.street,
        zip: row.zip,
        city: row.city,
        phone: row.phone,
        email: row.email,
        createdAt: row.createdAt,
        lat: row.lat,
        lon: row.lon,
      );
}

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(ref.watch(databaseProvider));
});

final clientsProvider = FutureProvider<List<model.Client>>((ref) {
  return ref.watch(clientRepositoryProvider).watchAll().first;
});

final clientByIdProvider =
    FutureProvider.family<model.Client?, String>((ref, id) {
  return ref.watch(clientRepositoryProvider).getById(id);
});
