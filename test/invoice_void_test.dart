import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/invoicing/invoice_service.dart';
import 'package:galabau_app/services/invoicing/number_assigner.dart';

void main() {
  late AppDatabase db;
  late InvoiceService service;

  const InvoiceLineInput line = InvoiceLineInput(
    position: 1,
    description: 'Heckenschnitt',
    quantityMilli: 1000,
    unit: 'Stück',
    unitPriceCents: 1000,
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = InvoiceService(db: db, assigner: NumberAssigner(db: db));
    // Fremdschlüssel: Rechnungen brauchen einen Kunden.
    await db.into(db.clients).insert(
          ClientsCompanion.insert(
            id: 'k-1',
            name: 'Max Mustermann',
            createdAt: DateTime(2026),
          ),
        );
  });

  tearDown(() async => db.close());

  test('voidInvoice erstellt Stornorechnung mit negativen Beträgen', () async {
    final original = await service.createInvoice(
      clientId: 'k-1',
      lines: const <InvoiceLineInput>[line],
      vatRateBp: 1900,
    );

    final storno = await service.voidInvoice(original.id);

    expect(storno.stornoOfId, original.id);
    expect(storno.number, startsWith('ST-'));
    expect(storno.netCents, -original.netCents);
    expect(storno.vatCents, -original.vatCents);
    expect(storno.grossCents, -original.grossCents);
    expect(storno.status, 'issued');
  });

  test('gestellte Rechnung ist unveränderlich (Trigger)', () async {
    final original = await service.createInvoice(
      clientId: 'k-1',
      lines: const <InvoiceLineInput>[line],
      vatRateBp: 1900,
    );

    await expectLater(
      (db.update(db.invoices)..where((t) => t.id.equals(original.id)))
          .write(const InvoicesCompanion(netCents: Value(1))),
      throwsA(isA<Object>()),
    );
    await expectLater(
      (db.delete(db.invoices)..where((t) => t.id.equals(original.id))).go(),
      throwsA(isA<Object>()),
    );
  });

  test('Entwurf bleibt editierbar', () async {
    final draft = await service.saveDraft(
      clientId: 'k-1',
      lines: const <InvoiceLineInput>[line],
      vatRateBp: 1900,
    );

    await (db.update(db.invoices)..where((t) => t.id.equals(draft.id)))
        .write(const InvoicesCompanion(netCents: Value(12345)));

    final updated =
        await (db.select(db.invoices)..where((t) => t.id.equals(draft.id)))
            .getSingle();
    expect(updated.netCents, 12345);
  });

  test('voidInvoice protokolliert einen audit_log-Eintrag', () async {
    final original = await service.createInvoice(
      clientId: 'k-1',
      lines: const <InvoiceLineInput>[line],
      vatRateBp: 1900,
    );

    await service.voidInvoice(original.id);

    final logs = await db.select(db.auditLog).get();
    expect(logs, hasLength(1));
    expect(logs.single.event, 'storno');
    expect(logs.single.objectId, original.id);
  });
}
