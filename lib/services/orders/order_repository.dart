import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order.dart' as model;
import '../../models/order_status.dart';
import '../database/app_database.dart';
import '../database/providers.dart';

/// CRUD-Zugriff auf Aufträge (`orders`).
class OrderRepository {
  const OrderRepository(this.db);

  final AppDatabase db;

  /// Alle Aufträge, neueste zuerst.
  Stream<List<model.Order>> watchAll() {
    final query = db.select(db.orders)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  /// Aufträge eines Kunden, neueste zuerst.
  Stream<List<model.Order>> watchByClient(String clientId) {
    final query = (db.select(db.orders)
          ..where((t) => t.clientId.equals(clientId)))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  Future<void> insert(model.Order order) => db.into(db.orders).insert(
        OrdersCompanion.insert(
          id: order.id,
          clientId: order.clientId,
          title: order.title,
          description: Value(order.description),
          createdAt: order.createdAt,
          dueDateStart: Value(order.dueDateStart),
          dueDateEnd: Value(order.dueDateEnd),
          status: Value(order.status),
          recurring: Value(order.recurring),
          notes: Value(order.notes),
        ),
      );

  Future<model.Order?> getById(String id) async {
    final row =
        await (db.select(db.orders)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Aktualisiert einen Auftrag.
  Future<void> update(model.Order order) =>
      (db.update(db.orders)..where((t) => t.id.equals(order.id)))
          .write(OrdersCompanion(
            clientId: Value(order.clientId),
            title: Value(order.title),
            description: Value(order.description),
            dueDateStart: Value(order.dueDateStart),
            dueDateEnd: Value(order.dueDateEnd),
            status: Value(order.status),
            recurring: Value(order.recurring),
            notes: Value(order.notes),
          ));

  /// Löscht einen Auftrag (Rechnungen/PDFs bleiben bestehen).
  Future<void> delete(String id) =>
      (db.delete(db.orders)..where((t) => t.id.equals(id))).go();
  Future<void> updateStatus(String id, OrderStatus status) =>
      (db.update(db.orders)..where((t) => t.id.equals(id)))
          .write(OrdersCompanion(status: Value(status)));

  model.Order _toModel(Order row) => model.Order(
        id: row.id,
        clientId: row.clientId,
        title: row.title,
        description: row.description,
        createdAt: row.createdAt,
        dueDateStart: row.dueDateStart,
        dueDateEnd: row.dueDateEnd,
        status: row.status,
        recurring: row.recurring,
        notes: row.notes,
      );
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(databaseProvider));
});

final ordersProvider = FutureProvider<List<model.Order>>((ref) {
  return ref.watch(orderRepositoryProvider).watchAll().first;
});
