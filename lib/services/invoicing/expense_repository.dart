import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/expense.dart' as model;
import '../database/app_database.dart';
import '../database/providers.dart';

/// CRUD-Zugriff auf Betriebsausgaben (Material/Fremd/Personal).
class ExpenseRepository {
  const ExpenseRepository(this.db);

  final AppDatabase db;

  Future<void> insert(model.Expense expense) => db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          id: expense.id,
          orderId: Value(expense.orderId),
          colleagueId: Value(expense.colleagueId),
          category: Value(expense.category),
          netCents: Value(expense.netCents),
          vatRateBp: Value(expense.vatRateBp),
          grossCents: Value(expense.grossCents),
          filePath: Value(expense.filePath),
          bookedAt: expense.bookedAt,
        ),
      );

  /// Ausgaben eines Auftrags, neueste zuerst.
  Future<List<model.Expense>> byOrder(String orderId) async {
    final query = (db.select(db.expenses)
          ..where((t) => t.orderId.equals(orderId)))
      ..orderBy([(t) => OrderingTerm.desc(t.bookedAt)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  model.Expense _toModel(Expense row) => model.Expense(
        id: row.id,
        category: row.category,
        netCents: row.netCents,
        vatRateBp: row.vatRateBp,
        grossCents: row.grossCents,
        bookedAt: row.bookedAt,
        orderId: row.orderId,
        colleagueId: row.colleagueId,
        filePath: row.filePath,
      );
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider));
});

final expensesByOrderProvider =
    FutureProvider.family<List<model.Expense>, String>((ref, orderId) {
  return ref.watch(expenseRepositoryProvider).byOrder(orderId);
});
