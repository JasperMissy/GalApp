import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/expense.dart' as model;
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/invoicing/expense_repository.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ExpenseRepository(db);
    // Fremdschlüssel: Ausgaben verweisen auf einen existierenden Auftrag.
    await db.into(db.orders).insert(
          OrdersCompanion.insert(
            id: 'a-1',
            title: 'Hecke',
            createdAt: DateTime(2026, 11, 1),
          ),
        );
  });

  tearDown(() async => db.close());

  test('insert und byOrder (neueste zuerst)', () async {
    await repo.insert(model.Expense(
      id: 'e-1',
      orderId: 'a-1',
      category: 'material',
      netCents: 100,
      vatRateBp: 1900,
      grossCents: 119,
      filePath: '/tmp/beleg.pdf',
      bookedAt: DateTime(2026, 11, 5, 10),
    ));
    await repo.insert(model.Expense(
      id: 'e-2',
      orderId: 'a-1',
      category: 'personal',
      netCents: 0,
      vatRateBp: 0,
      grossCents: 0,
      bookedAt: DateTime(2026, 11, 6, 10),
    ));

    final byOrder = await repo.byOrder('a-1');
    expect(byOrder, hasLength(2));
    expect(byOrder.first.id, 'e-2');
    expect(byOrder.first.category, 'personal');
    expect(byOrder.last.filePath, '/tmp/beleg.pdf');
  });

  test('Ausgabe ohne Auftragsbezug ist erlaubt', () async {
    await repo.insert(model.Expense(
      id: 'e-1',
      category: 'material',
      netCents: 0,
      vatRateBp: 0,
      grossCents: 0,
      bookedAt: DateTime(2026, 11, 5),
    ));

    expect(await repo.byOrder('a-1'), isEmpty);
  });
}
