import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order_package.dart' as model;
import '../database/app_database.dart';
import '../database/providers.dart';

/// Zugriff auf geteilte/empfangene Auftrags-Pakete.
class OrderPackageRepository {
  const OrderPackageRepository(this.db);

  final AppDatabase db;

  Future<void> insert(model.OrderPackage pkg) =>
      db.into(db.orderPackages).insert(
            OrderPackagesCompanion.insert(
              id: pkg.id,
              orderId: Value(pkg.orderId),
              colleagueId: Value(pkg.colleagueId),
              direction: Value(pkg.direction),
              status: Value(pkg.status),
              createdAt: pkg.createdAt,
            ),
          );

  /// Ein einzelnes Paket anhand seiner Paket-ID (oder null).
  Future<model.OrderPackage?> getByPackageId(String id) async {
    final row = await (db.select(db.orderPackages)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Pakete eines Auftrags, neueste zuerst.
  Stream<List<model.OrderPackage>> watchByOrder(String orderId) {
    final query = (db.select(db.orderPackages)
          ..where((t) => t.orderId.equals(orderId)))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  model.OrderPackage _toModel(OrderPackage row) => model.OrderPackage(
        id: row.id,
        orderId: row.orderId,
        colleagueId: row.colleagueId,
        direction: row.direction,
        status: row.status,
        createdAt: row.createdAt,
      );
}

final orderPackageRepositoryProvider = Provider<OrderPackageRepository>((ref) {
  return OrderPackageRepository(ref.watch(databaseProvider));
});
