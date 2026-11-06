import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/invoicing/invoice_repository.dart';

void main() {
  late AppDatabase db;
  late InvoiceRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InvoiceRepository(db);
  });

  tearDown(() async => db.close());

  test('issuedInvoices liefert nur gestellte Rechnungen, neueste zuerst', () async {
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: 'k-1', name: 'Berger', createdAt: DateTime(2026),
        ));
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
          id: 'r-1',
          number: const Value('RE-2026-0002'),
          clientId: 'k-1',
          status: const Value('issued'),
          createdAt: DateTime(2026, 11, 6),
        ));
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
          id: 'r-2',
          number: const Value('RE-2026-0001'),
          clientId: 'k-1',
          status: const Value('draft'),
          createdAt: DateTime(2026, 11, 5),
        ));

    final issued = await repo.issuedInvoices();
    expect(issued, hasLength(1));
    expect(issued.single.number, 'RE-2026-0002');
  });

  test('invoicesByOrder liefert Rechnungen eines Auftrags', () async {
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: 'k-1', name: 'Berger', createdAt: DateTime(2026),
        ));
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
          id: 'r-1',
          number: const Value('RE-2026-0001'),
          clientId: 'k-1',
          orderId: const Value('a-1'),
          status: const Value('issued'),
          createdAt: DateTime(2026, 11, 6),
        ));
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
          id: 'r-2',
          number: const Value('RE-2026-0002'),
          clientId: 'k-1',
          orderId: const Value('a-2'),
          status: const Value('issued'),
          createdAt: DateTime(2026, 11, 5),
        ));

    final invoices = await repo.invoicesByOrder('a-1');
    expect(invoices, hasLength(1));
    expect(invoices.single.number, 'RE-2026-0001');
  });

  test('invoicesByClient liefert Rechnungen eines Kunden', () async {
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: 'k-1', name: 'Berger', createdAt: DateTime(2026),
        ));
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: 'k-2', name: 'Müller', createdAt: DateTime(2026),
        ));
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
          id: 'r-1',
          number: const Value('RE-2026-0001'),
          clientId: 'k-1',
          status: const Value('issued'),
          createdAt: DateTime(2026, 11, 6),
        ));
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
          id: 'r-2',
          number: const Value('RE-2026-0002'),
          clientId: 'k-2',
          status: const Value('issued'),
          createdAt: DateTime(2026, 11, 5),
        ));

    final invoices = await repo.invoicesByClient('k-1');
    expect(invoices, hasLength(1));
    expect(invoices.single.number, 'RE-2026-0001');
  });
}